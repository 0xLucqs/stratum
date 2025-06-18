//! # Stratum Common Crate
//!
//! `stratum_common` is a utility crate designed to centralize
//! and manage the shared dependencies and utils across stratum crates.
#[cfg(feature = "bitcoin")]
pub use bitcoin;
pub use secp256k1;
pub const STRATUM_CAIRO_EXECUTABLE: &[u8] = include_bytes!("./stratum_cairo.executable.json");
pub const STRATUM_CAIRO_PROGRAM_HASH: [u8; 32] = [
    7, 88, 88, 171, 100, 97, 242, 225, 254, 11, 239, 62, 195, 179, 156, 254, 243, 52, 67, 163, 16,
    15, 242, 164, 163, 83, 196, 42, 196, 88, 109, 195,
];
