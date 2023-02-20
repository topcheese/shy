module cli

import os

fn shy_commit_hash() string {
	mut hash := ''
	git_exe := os.find_abs_path_of_executable('git') or { '' }
	if git_exe != '' {
		mut git_cmd := 'git -C "${exe_dir}" rev-parse --short HEAD'
		$if windows {
			git_cmd = 'git.exe -C "${exe_dir}" rev-parse --short HEAD'
		}
		res := os.execute(git_cmd)
		if res.exit_code == 0 {
			hash = res.output
		}
	}
	return hash.trim_space()
}

fn shy_tmp_work_dir() string {
	return os.join_path(os.temp_dir(), exe_name.replace(' ', '_').replace('.exe', '').to_lower())
}

fn shy_cache_dir() string {
	return os.join_path(os.cache_dir(), exe_name.replace(' ', '_').replace('.exe', '').to_lower())
}

fn version_full() string {
	return '${exe_version} ${exe_git_hash}'
}

fn version() string {
	mut v := '0.0.0'
	vmod := @VMOD_FILE
	if vmod.len > 0 {
		if vmod.contains('version:') {
			v = vmod.all_after('version:').all_before('\n').replace("'", '').replace('"',
				'').trim_space()
		}
	}
	return v
}

// run_subcommand runs any sub-command detected in `args`.
pub fn run_subcommand(args []string) ! {
	nocache := args.contains('--nocache')
	for subcmd in subcmds {
		if subcmd in args {
			// First encountered known sub-command is executed on the spot.
			launch_cmd(args[args.index(subcmd)..], nocache)!
			exit(0)
		}
	}
}

// is_windows_running_in_virtual_box returns `true` if the host system is
// Windows and it is running under VirtualBox.
pub fn is_windows_running_in_virtual_box() bool {
	mut cmd := ''
	$if windows {
		cmd = 'WMIC COMPUTERSYSTEM GET MODEL'
	}
	if cmd != '' {
		res := os.execute(cmd)
		if res.exit_code == 0 {
			return res.output.contains('VirtualBox')
		}
	}
	return false
}
