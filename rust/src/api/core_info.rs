/// Build information about the Rust core, used as the Phase 0b smoke test of the bridge.
pub struct CoreInfo {
    pub crate_version: String,
    /// `<arch>-<os>` of the compiled library, e.g. `x86_64-android`.
    pub target: String,
}

#[flutter_rust_bridge::frb(sync)]
pub fn core_info() -> CoreInfo {
    CoreInfo {
        crate_version: env!("CARGO_PKG_VERSION").to_string(),
        target: format!("{}-{}", std::env::consts::ARCH, std::env::consts::OS),
    }
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn reports_crate_version() {
        assert_eq!(core_info().crate_version, env!("CARGO_PKG_VERSION"));
    }

    #[test]
    fn reports_arch_and_os() {
        let info = core_info();
        assert!(info.target.starts_with(std::env::consts::ARCH));
        assert!(info.target.ends_with(std::env::consts::OS));
    }
}
