if Autoproj.user_config('DEB_USE')
    # Setup of the TYPELIB_PLUGIN_PATH
    typelib_plugin_path = nil
    if defined?(Autobuild.environment)
        typelib_plugin_path = Autobuild.environment['TYPELIB_PLUGIN_PATH']
    else
        typelib_plugin_path = Autobuild.env.environment['TYPELIB_PLUGIN_PATH']
    end

    # Make sure the release path to typelib is used, when there is no local
    # installation
    if !typelib_plugin_path || Dir.glob(File.join(typelib_plugin_path, "**")).empty?
        release_dir="/opt/rock/#{Autoproj.user_config('debian_release')}"
        Autoproj.env_set 'TYPELIB_PLUGIN_PATH', File.join(release_dir, 'lib','typelib')
    end
end

deb_cxx_flags = []
deb_cxx_flags << "-std=c++11"

Autobuild::Package.each do |name, pkg|
    if pkg.respond_to?(:define)
        existing_cxx_flags=pkg.defines['CMAKE_CXX_FLAGS']
        if existing_cxx_flags
            existing_cxx_flags = existing_cxx_flags.split(" ")
        else
            existing_cxx_flags = []
        end
        extra_cxx_flags  = Array.new

        deb_cxx_flags.each do |flag|
            if existing_cxx_flags.include?(flag)
                existing_cxx_flags.delete(flag)
            end
        end
        cxx_flags = deb_cxx_flags + existing_cxx_flags

        cxx_flags = cxx_flags.join(" ")
        if !cxx_flags.empty?
            pkg.define "CMAKE_CXX_FLAGS", cxx_flags
        end
    end
end
