module sui_token_contract::basic_token {
    use sui::coin::{Self, TreasuryCap};
    use sui::object::new;
    use sui::transfer::public_freeze_object;
    use sui::transfer::public_transfer;
    use sui::transfer::transfer;
    use sui::tx_context::{sender, TxContext};
    use std::option::none;

    /// The type identifier of coin
    public struct BASIC_TOKEN has drop {}

    /// Capability that allows minting and burning
    public struct MinterCap has key {
        id: sui::object::UID,
        treasury_cap: TreasuryCap<BASIC_TOKEN>
    }

    /// Module initializer called once on module publish
    fun init(witness: BASIC_TOKEN, ctx: &mut TxContext) {
        let (treasury_cap, metadata) = coin::create_currency(
            witness,
            8, // decimals
            b"BTKN", // symbol
            b"Basic Token", // name
            b"Description of the Basic Token", // description
            none(), // icon url
            ctx
        );
        public_freeze_object(metadata);
        
        // Create and share the MinterCap object
        let minter_cap = MinterCap {
            id: new(ctx),
            treasury_cap
        };
        transfer(minter_cap, sender(ctx));
    }

    /// Public initializer for testing purposes
    #[test_only]
    public fun init_for_testing(ctx: &mut TxContext) {
        init(BASIC_TOKEN {}, ctx)
    }

    /// Mint new tokens
    public entry fun mint(
        minter_cap: &mut MinterCap,
        amount: u64,
        recipient: address,
        ctx: &mut TxContext
    ) {
        let new_coin = coin::mint(&mut minter_cap.treasury_cap, amount, ctx);
        public_transfer(new_coin, recipient);
    }

    /// Transfer tokens
    public entry fun transfer_tokens(
        coin: coin::Coin<BASIC_TOKEN>,
        recipient: address,
    ) {
        public_transfer(coin, recipient);
    }

    /// Burn tokens
    public entry fun burn(
        minter_cap: &mut MinterCap,
        coin: coin::Coin<BASIC_TOKEN>
    ) {
        coin::burn(&mut minter_cap.treasury_cap, coin);
    }
}
