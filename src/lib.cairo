use starknet::ContractAddress;

#[starknet::interface]
trait I_BIRD_ERC721<T> {
    //-::- Admin
    fn add_token(
        ref self: T, _address: ContractAddress, _token_id: felt252, _details: BIRD_ERC721::Details,
    );
    fn transfer_token(
        ref self: T, _address: ContractAddress, _token_id: felt252, _to: ContractAddress,
    );
    fn start_auction_of(ref self: T, _address: ContractAddress, _token_id: felt252);
    fn close_auction_of(ref self: T, _address: ContractAddress, _token_id: felt252);

    // -::-
    fn auction_of(ref self: T, _token_id: felt252, _price: u64);
    fn owner_of(self: @T, _address: ContractAddress);
    // fn balance_of(self: @T, _address: ContractAddress) -> u64;
}

#[starknet::contract]
mod BIRD_ERC721 {
    use starknet::storage::StoragePathEntry;
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
    pub struct AuctionBidDetail {
        token_id: felt252,
        amount: u64,
    }

    #[storage]
    struct Storage {
        token_bids: Map<felt252, Details>,
        owner_of: Map<ContractAddress, Vec<u256>>,
        auction_bids_map: Map<ContractAddress, u64>,
        managers: Vec<ContractAddress>,
    }

    impl BIRD_ERC721_IMPL of super::I_BIRD_ERC721<ContractState> {
        fn add_token(
            ref self: ContractState,
            _address: ContractAddress,
            _token_id: felt252,
            _details: Details,
        ) {
            // verfication
            assert(verify_manager(@self).is_some(), 'Erro: Unauthorized');
            self.token_bids.entry(_token_id).write(_details);
        }


        //
        fn transfer_token(
            ref self: ContractState,
            _address: ContractAddress,
            _token_id: felt252,
            _to: ContractAddress,
        ) {}

        //
        fn start_auction_of(
            ref self: ContractState, _address: ContractAddress, _token_id: felt252,
        ) {}

        //
        fn close_auction_of(
            ref self: ContractState, _address: ContractAddress, _token_id: felt252,
        ) {}

        //
        fn auction_of(ref self: ContractState, _token_id: felt252, _price: u64) {}

        //
        fn owner_of(self: @ContractState, _address: ContractAddress) {}
        // // -::-
    }

    // Utils
    fn verify_manager(self: @ContractState) -> Option<bool> {
        let caller = get_caller_address();
        for i in 0..self.managers.len() {
            let mut _element = self.managers.at(i).read();
            if _element == caller {
                Option::Some(2);
                break;
            }
        };
        return Option::None; // Fixed: Return the default value outside the loop//+
    }
}
