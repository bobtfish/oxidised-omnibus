class PuppetOmnibus < FPM::Cookery::Recipe
  homepage 'https://github.com/bobtfish/puppet-omnibus'

  section 'Utilities'
  name 'oxidized-omnibus'
  version '3.0.2'
  description 'Oxidized Omnibus package'
  revision ENV['BUILD_NUMBER']
  uname = `uname -a`
  if uname =~ /Linux/
    if File.exists?('/etc/redhat-release')
      redhat = IO.read('/etc/redhat-release')
      releaseno = /CentOS release (\d)/.match(redhat)[1]
      vendor "yelp-centos#{releaseno}-"
    else
      codename = `cat /etc/lsb-release | grep CODENAME | cut -d= -f2`.chomp
      vendor "yelp-#{codename}-"
    end 
  else
    vendor 'yelp-darwin'
  end
  maintainer '<tdoran@yelp.com>'
  license 'Apache 2.0 License'

  source '', :with => :noop

  omnibus_package true
  omnibus_dir     "/opt/#{name}"
  omnibus_recipes 'libyaml',
                  'libyaml',
                  'ruby',
                  'oxidized'

  def build
    # Nothing
  end

  def install
    # Set paths to package scripts
    self.class.post_install builddir('post-install')
    self.class.pre_uninstall builddir('pre-uninstall')
  end

end

