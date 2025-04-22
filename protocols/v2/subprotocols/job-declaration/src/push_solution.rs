use alloc::vec::Vec;
use binary_sv2::{binary_codec_sv2, Deserialize, Serialize, B032, U256};
use core::convert::TryInto;

/// Message used by JDC to push a solution to JDS as soon as it finds a new valid block.
///
/// Upon receiving this message, JDS should propagate the new block as soon as possible.
///
/// Note that JDC is also expected to share the new block data through `SubmitSolution` message
/// under the Template Distribution Protocol.
#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, Eq)]
#[repr(C)]
pub struct PushSolution<'decoder> {
    /// Full extranonce that forms a valid submission.
    pub extranonce: B032<'decoder>,
    /// Previous block hash.
    pub prev_hash: U256<'decoder>,
    /// Contains the time the block was constructed as a Unix timestamp.
    pub ntime: u32,
    /// Nonce of the block.
    pub nonce: u32,
    /// The bits field is compact representation of the target at the time the block was mined.
    pub nbits: u32,
    /// The version field in a Bitcoin header initially indicated protocol rule changes. [`BIP9`]
    /// altered its use by turning it into a bit vector for coordinated soft fork signaling.
    /// [`BIP320`] further refined its purpose by dedicating 16 bits(starting from 13 to 28) of the
    /// version field for general-purpose miner use, ensuring that such usage doesn't interfere
    /// with the soft fork signaling mechanism defined by [`BIP9`].
    ///
    /// [`BIP9`]: https://en.bitcoin.it/wiki/BIP_0009
    /// [`BIP320`]: https://en.bitcoin.it/wiki/BIP_0320
    pub version: u32,
}
