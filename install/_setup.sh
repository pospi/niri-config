# buildsystem dependencies- pretty much everything else depends on these
. build_deps.sh

# initalise package registries for install commands to pull from
. package_registries.sh

# dependencies organised by function/purpose
. window_manager.sh
. notifications.sh
. x11_compat.sh
. taskbar.sh
. idle_lock.sh
. app_launcher.sh
. misc_utils.sh
