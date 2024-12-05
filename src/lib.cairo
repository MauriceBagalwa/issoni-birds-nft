use starknet::ContractAddress;
use core::starknet::storage::{Vec};

#[starknet::interface]
pub trait I_BIRD_ERC721<T> {
    //-::- Admin
    fn add_token(ref self: T, _input: BIRD_ERC721::TokenBids);
    fn get_auction_bids(self: @T) -> Array<BIRD_ERC721::TokenBids>;
    fn transfer_token(
        ref self: T, _address: ContractAddress, _token_id: felt252, _to: ContractAddress,
    );
    fn start_auction_of(ref self: T, _address: ContractAddress, _token_id: felt252);
    fn close_auction_of(ref self: T, _address: ContractAddress, _token_id: felt252);

    // -::-
    fn auction_of(ref self: T, _token_id: felt252, _price: u64) -> BIRD_ERC721::TokenBids;
    fn owner_of(self: @T, _address: ContractAddress) -> Vec<BIRD_ERC721::TokenBids>;
}

#[starknet::contract]
mod BIRD_ERC721 {
    use starknet::event::EventEmitter;
    use starknet::storage::MutableVecTrait;
    use core::starknet::storage::{
        StoragePointerReadAccess, StoragePointerWriteAccess, Map, Vec, VecTrait,
    };
    use core::starknet::{ContractAddress, get_caller_address};

    #[derive(Drop, Serde, starknet::Store)]
    pub struct Details {
        status: bool,
        description: felt252,
    }

    #[derive(Drop, Serde, starknet::Store)]
    pub struct TokenBids {
        token: felt252,
        details: Details,
    }


    #[derive(Drop, Serde, starknet::Store)]
    pub struct AuctionBidDetail {
        token_id: felt252,
        amount: u64,
    }

    #[storage]
    struct Storage {
        token_bids: Vec<TokenBids>,
        owner_of: Map<ContractAddress, Vec<u256>>,
        auction_bids_map: Map<ContractAddress, u64>,
        managers: Vec<ContractAddress>,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        let me = get_caller_address();
        self.managers.append().write(me);
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        TokenAdded: TokenAdded,
    }

    #[derive(Drop, starknet::Event)]
    pub struct TokenAdded {
        #[key]
        _address: ContractAddress,
        // _token: felt252,
    }

    impl BIRD_ERC721_IMPL of super::I_BIRD_ERC721<ContractState> {
        //
        fn get_auction_bids(self: @ContractState) -> Array<TokenBids> {
            // let result = Option::None;
            let mut addresses = array![];
            for i in 0..self.token_bids.len() {
                let mut _item = self.token_bids.at(i).read();
                addresses.append(_item);
            };
            addresses
        }

        //
        fn add_token(ref self: ContractState, _input: TokenBids) {
            // verfication
            assert(verify_manager(@self), 'Erro: Unauthorized');
            let caller = get_caller_address();
            self.token_bids.append().write(_input);

            self.emit(TokenAdded { _address: caller });
        }


        fn transfer_token(
            ref self: ContractState,
            _address: ContractAddress,
            _token_id: felt252,
            _to: ContractAddress,
        ) {}

        fn start_auction_of(
            ref self: ContractState, _address: ContractAddress, _token_id: felt252,
        ) {}
        fn close_auction_of(
            ref self: ContractState, _address: ContractAddress, _token_id: felt252,
        ) {}

        // -::-
        fn auction_of(ref self: ContractState, _token_id: felt252, _price: u64) -> TokenBids {}

        fn owner_of(self: @ContractState, _address: ContractAddress) -> Vec<TokenBids> {}
    }

    // Utils
    fn verify_manager(self: @ContractState) -> bool {
        let mut find = false;
        let caller = get_caller_address();
        for i in 0..self.managers.len() {
            let mut _element = self.managers.at(i).read();
            if caller == _element {
                find = true;
                break;
            }
        };
        return false; // Fixed: Return the default value outside the loop//+
    }
}
