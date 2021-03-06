class PuppetGem < FPM::Cookery::Recipe
  description 'Oxidized gem stack'

  name 'oxidized'
  version '0.3.0'

  source "nothing", :with => :noop

  platforms [:ubuntu, :debian] do
    build_depends 'pkg-config', 'libsqlite3-dev'
    depends 'pkg-config', 'libsqlite3-0'
  end

  platforms [:fedora, :redhat, :centos] do
    build_depends 'pkgconfig', 'sqlite-devel'
    depends 'pkgconfig', 'sqlite'
  end

  def build
    # Install gems using the gem command from destdir
    gem_install name,          version
    # Download init scripts and conf
    build_files
  end

  def install
    # Install init-script and puppet.conf
    install_files

    # Provide 'safe' binaries in /opt/<package>/bin like Vagrant does
    rm_rf "#{destdir}/../bin"
    destdir('../bin').mkdir
    destdir('../bin').install workdir('omnibus.bin'), 'oxidized'

    # Symlink binaries to PATH using update-alternatives
    with_trueprefix do
      create_post_install_hook
      create_pre_uninstall_hook
    end
  end

  private

  def gem_install(name, version = nil)
    v = version.nil? ? '' : "-v #{version}"
    cleanenv_safesystem "#{destdir}/bin/gem install --no-ri --no-rdoc #{v} #{name}"
  end

  platforms [:ubuntu, :debian] do
    def build_files
    end
    def install_files
    #  etc('puppet').mkdir
    #  etc('default').install builddir('puppet.default') => 'puppet'
    end
  end

  platforms [:fedora, :redhat, :centos] do
    def build_files
    end
    def install_files
    #  etc('puppet').mkdir
    end
  end

  def create_post_install_hook
    File.open(builddir('post-install'), 'w', 0755) do |f|
      f.write <<-__POSTINST
#!/bin/sh
set -e

echo "Not setting up binstubs to /usr/bin"
exit 0

BIN_PATH="#{destdir}/bin"
BINS="puppet facter hiera"

for BIN in $BINS; do
  update-alternatives --install /usr/bin/$BIN $BIN $BIN_PATH/$BIN 100
done

exit 0
      __POSTINST
    end
  end

  def create_pre_uninstall_hook
    File.open(builddir('pre-uninstall'), 'w', 0755) do |f|
      f.write <<-__PRERM
#!/bin/sh
set -e

BIN_PATH="#{destdir}/bin"
BINS="puppet facter hiera"

if [ "$1" != "upgrade" ]; then
  for BIN in $BINS; do
    update-alternatives --remove $BIN $BIN_PATH/$BIN
  done
fi

exit 0
      __PRERM
    end
  end

end
