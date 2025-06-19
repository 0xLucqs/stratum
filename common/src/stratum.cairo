use core::array::Array;
use core::iter::Iterator;

#[derive(Drop, Clone, Debug, PartialEq, Serde)]
pub struct TxOut {
    pub value: u64,
    pub script_pubkey: ByteArray,
}


#[executable]
pub fn main(coinbase_output: u64, fees: Array<u64>, block_reward: u64) {
    assert!(block_reward + fees.into_iter().sum() == coinbase_output);
}
