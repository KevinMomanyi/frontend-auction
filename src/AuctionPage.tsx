import React from 'react';

const AuctionPage: React.FC<{ contractAddress: string }> = ({ contractAddress }) => {
  return (
    <div className="min-h-screen bg-gray-50">
      {/* Navbar */}
      <header className="bg-gradient-to-r from-purple-500 to-indigo-500 text-white py-4 shadow-md">
        <div className="max-w-6xl mx-auto flex items-center justify-between px-6">
          <h1 className="text-2xl font-bold">NFT Auction</h1>
          <nav className="space-x-6">
            <a href="#" className="text-sm hover:text-gray-200">Home</a>
            <a href="#" className="text-sm hover:text-gray-200">My Bids</a>
            <a href="#" className="text-sm hover:text-gray-200">Profile</a>
          </nav>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-6xl mx-auto p-6 grid md:grid-cols-3 gap-8 mt-6">
        {/* Auction Details */}
        <section className="md:col-span-2 bg-white rounded-lg shadow-lg p-6">
          <h2 className="text-lg font-semibold text-gray-800 mb-4">Auction Details</h2>
          <div className="bg-gray-100 p-4 rounded-lg mb-6">
            <p className="text-sm text-gray-600">
              Contract Address:
              <span className="ml-2 font-mono bg-gray-200 px-2 py-1 rounded text-xs shadow-inner">
                {contractAddress}
              </span>
            </p>
          </div>
          <div className="grid grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700">Current Bid</label>
              <div className="mt-1 flex items-center">
                <span className="text-3xl font-extrabold text-green-600">0.05 ETH</span>
              </div>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">Time Remaining</label>
              <div className="mt-1">
                <span className="text-2xl font-semibold text-red-500">
                  2d 5h 30m
                </span>
              </div>
            </div>
          </div>
        </section>

        {/* NFT and Actions */}
        <section className="bg-white rounded-lg shadow-lg p-6 flex flex-col items-center">
          <img
            src="/api/placeholder/400/300"
            alt="NFT"
            className="w-full rounded-lg shadow-md mb-4"
          />
          <button className="w-full bg-gradient-to-r from-blue-500 to-purple-600 text-white py-3 rounded-lg shadow-lg hover:opacity-90 transition">
            Place Bid
          </button>
          <button className="w-full mt-4 border border-blue-500 text-blue-600 py-3 rounded-lg hover:bg-blue-50 transition">
            View Details
          </button>
        </section>
      </main>

      {/* Footer */}
      <footer className="mt-12 py-6 bg-gray-100">
        <div className="max-w-6xl mx-auto text-center text-sm text-gray-600">
          © 2024 NFT Auction Platform. All rights reserved.
        </div>
      </footer>
    </div>
  );
};

export default AuctionPage;
