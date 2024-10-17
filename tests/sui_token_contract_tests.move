#[test_only]
module sui_token_contract::basic_token_tests {
    use sui::test_scenario;
    use sui::coin::{Self, Coin};
    use sui_token_contract::basic_token::{Self, BASIC_TOKEN, MinterCap};

    // Test constants
    const ADMIN: address = @0xA11CE;
    const USER1: address = @0xB0B;
    const USER2: address = @0xAE;
    const MINT_AMOUNT: u64 = 1000;
    const TRANSFER_AMOUNT: u64 = 500;

    #[test]
    fun test_basic_token_flow() {
        let mut scenario = test_scenario::begin(ADMIN);
        
        // Test initialization
        {
            basic_token::init_for_testing(test_scenario::ctx(&mut scenario));
        };

        // Test minting
        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            let mut minter_cap = test_scenario::take_from_sender<MinterCap>(&scenario);
            basic_token::mint(&mut minter_cap, MINT_AMOUNT, USER1, test_scenario::ctx(&mut scenario));
            test_scenario::return_to_sender(&scenario, minter_cap);
        };

        // Verify minted coins
        test_scenario::next_tx(&mut scenario, USER1);
        {
            let coin = test_scenario::take_from_sender<Coin<BASIC_TOKEN>>(&scenario);
            assert!(coin::value(&coin) == MINT_AMOUNT, 0);
            test_scenario::return_to_sender(&scenario, coin);
        };

        // Test transfer
        test_scenario::next_tx(&mut scenario, USER1);
        {
            let mut coin = test_scenario::take_from_sender<Coin<BASIC_TOKEN>>(&scenario);
            let split_coin = coin::split(&mut coin, TRANSFER_AMOUNT, test_scenario::ctx(&mut scenario));
            sui::transfer::public_transfer(split_coin, USER2);
            test_scenario::return_to_sender(&scenario, coin);
        };

        // Verify transfer
        test_scenario::next_tx(&mut scenario, USER1);
        {
            let coin = test_scenario::take_from_sender<Coin<BASIC_TOKEN>>(&scenario);
            assert!(coin::value(&coin) == MINT_AMOUNT - TRANSFER_AMOUNT, 1);
            test_scenario::return_to_sender(&scenario, coin);
        };

        test_scenario::next_tx(&mut scenario, USER2);
        {
            let coin = test_scenario::take_from_sender<Coin<BASIC_TOKEN>>(&scenario);
            assert!(coin::value(&coin) == TRANSFER_AMOUNT, 2);
            test_scenario::return_to_sender(&scenario, coin);
        };

        // Test burning
        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            let mut minter_cap = test_scenario::take_from_sender<MinterCap>(&scenario);
            let coin = test_scenario::take_from_address<Coin<BASIC_TOKEN>>(&scenario, USER2);
            basic_token::burn(&mut minter_cap, coin);
            test_scenario::return_to_sender(&scenario, minter_cap);
        };

        // Verify burn
        test_scenario::next_tx(&mut scenario, USER2);
        {
            assert!(!test_scenario::has_most_recent_for_sender<Coin<BASIC_TOKEN>>(&scenario), 3);
        };

        test_scenario::end(scenario);
    }
}
