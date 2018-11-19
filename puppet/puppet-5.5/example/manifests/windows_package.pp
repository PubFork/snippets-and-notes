# deploys a windows package and performs all necessary common support functionality
define example::windows_package(
  Optional[Array] $install_options      = [],
  Optional[Array] $uninstall_options    = [],
  Optional[Boolean] $postinstall_reboot = false,
  Optional[Boolean] $downgradeable      = true,
  String $ensure                        = 'present',
  String $pkg_name                      = $title,
  String $repo_path                     = undef,
  Optional[String] $installer           = 'setup.exe',
  Optional[String] $installed_version   = undef,
){
  # TODO: versioncmp conditionals assume $ensure is a version string
  # if 'installed_version' param was specified, it means the package does not show up in the windows installed list and the currently installed version was passed in as that param
  if $installed_version {
    $filtered_pkg = []
    # if the desired version is already installed OR the package cannot be downgraded and a downgrade would be attempted, then construct a suitable array for desired behavior of an idempotent package resource
    if ($installed_version == $ensure) or ((!$downgradeable) and (versioncmp($ensure, $installed_version) < 0)) {
      $filtered_pkg = [$pkg_name, $installed_version, 'windows']
    }
  }
  # else parse array of installed packages and filter out an array containing the desired package at the desired version
  elsif has_key($facts, '_puppet_inventory_1') {
    $filtered_pkg = $facts['_puppet_inventory_1']['packages'].filter |Array $package| {
      $package[0] == $pkg_name and
      # check for either installed at the desired version or cannot be downgraded and installed at a later version than desired
      (($package[1] == $ensure) or ((!$downgradeable) and (versioncmp($ensure, $package[1]) == -1))) and
      $package[2] == 'windows'
    }
  }
  # split on repo path to determine archive name or installer name; therefore, installer name must be specified if package is an archive
  $pkg_file = split($repo_path, '/')[-1]
  # install the package at the desired version because it was not found on the system
  if empty($filtered_pkg) {
    # retrieve archive
    if $pkg_file =~ /(.*)\.zip$/ {
      require sigi_sevenzip
      # establish directory containing installer files
      $dest = "C:\\Windows\\TEMP\\${1}\\${installer}"
      # establish directory for cleanup
      $cleanup = "C:\\Windows\\TEMP\\${1}"
      archive { "download and extract ${pkg_file} for ${pkg_name}":
        ensure        => present,
        path          => "C:\\Windows\\TEMP\\${pkg_file}",
        extract       => true,
        extract_flags => "x -o${cleanup}",
        extract_path  => 'C:\Windows\TEMP',
        source        => "http://tape-is01p.sigi.us.selective.com/package/${repo_path}",
        creates       => $cleanup,
        cleanup       => true,
        before        => Package[$pkg_name],
      }
    }
    # retrieve installer
    else {
      # establish directory containing installer file
      $dest = "C:\\Windows\\TEMP\\${pkg_file}"
      # establish file for cleanup
      $cleanup = "C:\\Windows\\TEMP\\${pkg_file}"
      download_file { "download ${pkg_file} for ${pkg_name}":
        url                   => "http://tape-is01p.sigi.us.selective.com/package/${repo_path}",
        destination_directory => 'C:\Windows\TEMP',
        before                => Package[$pkg_name],
      }
    }

    # install package from given source at specified version with specified options
    package { $pkg_name:
      ensure            => $ensure,
      source            => $dest,
      install_options   => $install_options,
      uninstall_options => $uninstall_options,
    }

    # cleanup directory or installer
    file { $cleanup:
      ensure  => absent,
      force   => true,
      require => Package[$pkg_name],
    }

    # trigger a reboot after puppet finishes applying catalog if necessary
    if $postinstall_reboot {
      reboot { "${pkg_name} requests reboot":
        apply     => finished,
        subscribe => Package[$pkg_name],
      }
    }
  }
  # create an idempotent package resource because it was found on the system unless windows does not recognize the package installation
  elsif (!$installed_version) {
    # create idempotent resource for necessary dependencies
    package { $pkg_name: ensure => $ensure }
  }
}
