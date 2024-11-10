#[starknet::contract]
mod NFTAuction {
    use starknet::ContractAddress;
    use starknet::get_block_timestamp;
    use starknet::{contract_address_const};
    use zeroable::Zeroable;
    use starknet::contract_address::ContractAddressZeroable;

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        AuctionCreated: AuctionCreated,
        BidPlaced: BidPlaced,
        AuctionEnded: AuctionEnded,
    }

    #[derive(Drop, starknet::Event)]
    struct AuctionCreated {
        nft_contract: ContractAddress,
        token_id: u256,
        start_price: u256,
        end_time: u64,
    }

    #[derive(Drop, starknet::Event)]
    struct BidPlaced {
        bidder: ContractAddress,
        amount: u256,
    }

    #[derive(Drop, starknet::Event)]
    struct AuctionEnded {
        winner: ContractAddress,
        amount: u256,
    }

    #[storage]
    struct Storage {
        nft_contract: ContractAddress,
        token_id: u256,
        start_price: u256,
        end_time: u64,
        highest_bidder: ContractAddress,
        highest_bid: u256,
        active: bool,
        owner: ContractAddress,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        owner: ContractAddress,
        nft_contract: ContractAddress,
        token_id: u256,
        start_price: u256,
        duration: u64,
    ) {
        let current_time = get_block_timestamp();
        self.owner.write(owner);
        self.nft_contract.write(nft_contract);
        self.token_id.write(token_id);
        self.start_price.write(start_price);
        self.end_time.write(current_time + duration);
        self.highest_bid.write(0);
        self.highest_bidder.write(contract_address_const::<0>());
        self.active.write(true);

        self.emit(Event::AuctionCreated(AuctionCreated {
            nft_contract: nft_contract,
            token_id: token_id,
            start_price: start_price,
            end_time: current_time + duration,
        }));
    }

    #[external(v0)]
    fn place_bid(ref self: ContractState) {
        // Get caller's address and bid amount from the transaction
        let caller = starknet::get_caller_address();
        let bid_amount = starknet::get_tx_info().unbox().value;
        
        // Check auction is still active
        assert!(self.active.read(), 'Auction ended');
        assert!(get_block_timestamp() < self.end_time.read(), 'Auction expired');
        
        // Check bid is higher than current highest bid
        let current_highest = self.highest_bid.read();
        assert!(bid_amount > current_highest, 'Bid too low');
        assert!(bid_amount >= self.start_price.read(), 'Below start price');

        // Update highest bid
        self.highest_bidder.write(caller);
        self.highest_bid.write(bid_amount);

        self.emit(Event::BidPlaced(BidPlaced {
            bidder: caller,
            amount: bid_amount,
        }));
    }

    #[external(v0)]
    fn end_auction(ref self: ContractState) {
        // Only owner can end auction
        assert!(starknet::get_caller_address() == self.owner.read(), 'Not authorized');
        assert!(self.active.read(), 'Already ended');
        assert!(get_block_timestamp() >= self.end_time.read(), 'Not ended yet');

        let winner = self.highest_bidder.read();
        let winning_bid = self.highest_bid.read();

        // Mark auction as ended
        self.active.write(false);

        self.emit(Event::AuctionEnded(AuctionEnded {
            winner: winner,
            amount: winning_bid,
        }));
    }

    // View functions
    #[view(v0)]
    fn get_highest_bid(self: @ContractState) -> u256 {
        self.highest_bid.read()
    }

    #[view(v0)]
    fn get_highest_bidder(self: @ContractState) -> ContractAddress {
        self.highest_bidder.read()
    }

    #[view(v0)]
    fn get_auction_end_time(self: @ContractState) -> u64 {
        self.end_time.read()
    }

    #[view(v0)]
    fn is_active(self: @ContractState) -> bool {
        self.active.read()
    }
}
