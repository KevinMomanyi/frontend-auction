#[cfg(test)]
mod tests {
    use super::NFTAuction;
    use starknet::{ContractAddress, contract_address_const, get_block_timestamp};
    use starknet::testing::{set_caller_address, set_block_timestamp, set_contract_address, set_transaction_hash};
    use integer::u256;
    use debug::PrintTrait;

    // Test Constants
    const HOUR: u64 = 3600;
    const DAY: u64 = 86400;

    // Helper function to create test addresses
    fn create_address(num: u32) -> ContractAddress {
        contract_address_const::<num>()
    }

    // Setup function to deploy auction contract
    fn setup() -> (ContractAddress, NFTAuction::ContractState) {
        let owner = create_address(1);
        let nft_contract = create_address(2);
        let current_time = 100;

        // Set initial conditions
        set_block_timestamp(current_time);
        set_caller_address(owner);

        // Deploy contract
        let mut state = NFTAuction::contract_state_for_testing();
        NFTAuction::constructor(
            ref state,
            owner,
            nft_contract,
            u256 { low: 1, high: 0 }, // token_id
            u256 { low: 1000, high: 0 }, // start_price
            DAY // duration
        );

        (owner, state)
    }

    // Unit Tests
    
    #[test]
    fn test_constructor() {
        let (owner, state) = setup();
        
        assert!(state.active.read() == true, 'Auction should be active');
        assert!(state.owner.read() == owner, 'Owner should be set');
        assert!(state.start_price.read() == u256 { low: 1000, high: 0 }, 'Start price should be set');
        assert!(state.highest_bid.read() == u256 { low: 0, high: 0 }, 'Initial bid should be 0');
        assert!(state.highest_bidder.read().is_zero(), 'No initial bidder');
    }

    #[test]
    fn test_place_valid_bid() {
        let (owner, mut state) = setup();
        let bidder = create_address(3);
        
        // Setup bid conditions
        set_caller_address(bidder);
        set_contract_address(bidder);
        
        // Place bid
        state.place_bid();
        
        assert!(state.highest_bidder.read() == bidder, 'Bidder should be highest');
        assert!(state.highest_bid.read() > u256 { low: 0, high: 0 }, 'Bid should be recorded');
    }

    #[test]
    #[should_panic(expected: ('Bid too low', ))]
    fn test_place_low_bid() {
        let (owner, mut state) = setup();
        let bidder1 = create_address(3);
        let bidder2 = create_address(4);
        
        // First bid
        set_caller_address(bidder1);
        set_contract_address(bidder1);
        state.place_bid();
        
        // Second lower bid (should fail)
        set_caller_address(bidder2);
        set_contract_address(bidder2);
        state.place_bid();
    }

    #[test]
    #[should_panic(expected: ('Auction expired', ))]
    fn test_bid_after_end_time() {
        let (owner, mut state) = setup();
        let bidder = create_address(3);
        
        // Move time past end
        set_block_timestamp(get_block_timestamp() + DAY + 1);
        
        // Try to bid
        set_caller_address(bidder);
        set_contract_address(bidder);
        state.place_bid();
    }

    #[test]
    fn test_end_auction() {
        let (owner, mut state) = setup();
        let bidder = create_address(3);
        
        // Place bid
        set_caller_address(bidder);
        set_contract_address(bidder);
        state.place_bid();
        
        // Move time to end
        set_block_timestamp(get_block_timestamp() + DAY + 1);
        
        // End auction
        set_caller_address(owner);
        state.end_auction();
        
        assert!(!state.active.read(), 'Auction should be inactive');
    }

    #[test]
    #[should_panic(expected: ('Not authorized', ))]
    fn test_end_auction_not_owner() {
        let (owner, mut state) = setup();
        let not_owner = create_address(5);
        
        set_block_timestamp(get_block_timestamp() + DAY + 1);
        set_caller_address(not_owner);
        state.end_auction();
    }

    // Integration Tests

    #[test]
    fn test_full_auction_flow() {
        let (owner, mut state) = setup();
        let bidder1 = create_address(3);
        let bidder2 = create_address(4);
        
        // First bid
        set_caller_address(bidder1);
        set_contract_address(bidder1);
        state.place_bid();
        
        // Second higher bid
        set_caller_address(bidder2);
        set_contract_address(bidder2);
        state.place_bid();
        
        // Verify highest bidder
        assert!(state.get_highest_bidder() == bidder2, 'Wrong highest bidder');
        
        // Move time forward and end auction
        set_block_timestamp(get_block_timestamp() + DAY + 1);
        set_caller_address(owner);
        state.end_auction();
        
        // Verify auction ended correctly
        assert!(!state.is_active(), 'Auction should be ended');
        assert!(state.get_highest_bidder() == bidder2, 'Final winner incorrect');
    }

    #[test]
    fn test_auction_no_bids() {
        let (owner, mut state) = setup();
        
        // Move time forward
        set_block_timestamp(get_block_timestamp() + DAY + 1);
        
        // End auction with no bids
        set_caller_address(owner);
        state.end_auction();
        
        assert!(!state.is_active(), 'Auction should be ended');
        assert!(state.get_highest_bidder().is_zero(), 'Should have no winner');
        assert!(state.get_highest_bid() == u256 { low: 0, high: 0 }, 'Should have no bids');
    }
}
