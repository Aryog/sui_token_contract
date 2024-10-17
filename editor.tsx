curl--location--request POST 'https://faucet.testnet.sui.io/gas' \
--header 'Content-Type: application/json' \
--data - raw '{
"FixedAmountRequest": {
	"recipient": "0x2a44f8a47f6ceae7f9ffeb9df23fb6859372f8b46c154c831a70330be0b7ce02"
}
}'
