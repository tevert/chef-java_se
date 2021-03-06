require 'spec_helper'

describe 'java_se::default' do
  context 'linux' do
    context 'set_java_home'do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(file_cache_path: '/var/chef/cache', platform: 'debian', version: '8.0') do |node|
          node.set['java_se']['java_home'] = '/opt/java'
        end.converge(described_recipe)
      end

      it 'it should set the java home environment variable' do
        expect(chef_run).to run_ruby_block('set-env-java-home')
        expect(chef_run).to_not run_ruby_block('Set JAVA_HOME in /etc/environment')
      end

      it 'should create the profile.d directory' do
        expect(chef_run).to create_directory('/etc/profile.d')
      end

      it 'should create jdk.sh with the java home environment variable' do
        expect(chef_run).to render_file('/etc/profile.d/jdk.sh').with_content('export JAVA_HOME=/opt/java')
      end

      it 'symlinks /opt/default-java' do
        link = chef_run.link('/opt/default-java')
        expect(link).to_not link_to('/opt/java')
      end
    end

    context 'set_java_home_environment' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(file_cache_path: '/var/chef/cache', platform: 'debian', version: '8.0') do |node|
          node.set['java_se']['java_home'] = '/opt/java'
          node.set['java_se']['set_etc_environment'] = true
        end.converge(described_recipe)
      end

      it 'installs open_uri_redirections gem' do
        expect(chef_run).to install_chef_gem('open_uri_redirections')
      end

      it 'installs glibc package' do
        expect(chef_run).to_not install_package('glibc')
      end

      it 'installs tar package' do
        expect(chef_run).to install_package('tar')
      end

      it 'it should set the java home environment variable' do
        expect(chef_run).to run_ruby_block('set-env-java-home')
      end

      it 'should create the profile.d directory' do
        expect(chef_run).to create_directory('/etc/profile.d')
      end

      it 'should create /etc/environment with the java home  variable' do
        expect(chef_run).to run_ruby_block('set JAVA_HOME in /etc/environment')
      end

      it 'add java' do
        expect(chef_run).to run_ruby_block('adding java to /opt/jdk1.8.0_60')
      end

      it 'symlink java' do
        expect(chef_run).to run_ruby_block('symlink /opt/jdk1.8.0_60 to /opt/java')
      end

      it 'validates java' do
        expect(chef_run).to create_template('adding /opt/.java.jinfo for debian')
      end

      it 'symlinks /usr/lib/jvm/default-java' do
        link = chef_run.link('/usr/lib/jvm/default-java')
        expect(link).to_not link_to('/usr/lib/jvm/java')
      end
    end

    context 'centos' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(file_cache_path: '/var/chef/cache', platform: 'centos', version: '7.0') do
        end.converge(described_recipe)
      end

      it 'fetches java' do
        expect(chef_run).to run_ruby_block(
          'fetch http://download.oracle.com/otn-pub/java/jdk/8u60-b27/jdk-8u60-linux-x64.tar.gz')
      end

      it 'validates java' do
        expect(chef_run).to run_ruby_block('validate /var/chef/cache/jdk-8u60-linux-x64.tar.gz')
      end

      it 'installs glibc package' do
        expect(chef_run).to_not install_yum_package('glibc')
      end

      it 'installs tar package' do
        expect(chef_run).to install_package('tar')
      end

      it 'add java' do
        expect(chef_run).to run_ruby_block('adding java to /usr/lib/jvm/jdk1.8.0_60')
      end

      it 'symlink java' do
        expect(chef_run).to run_ruby_block('symlink /usr/lib/jvm/jdk1.8.0_60 to /usr/lib/jvm/java')
      end

      it 'validates java' do
        expect(chef_run).to_not create_template('adding /usr/lib/jvm/.java.jinfo for debian')
      end

      it 'update-alternatives' do
        expect(chef_run).to run_ruby_block('update-alternatives')
      end

      it 'symlinks /usr/lib/jvm/default-java' do
        link = chef_run.link('/usr/lib/jvm/default-java')
        expect(link).to_not link_to('/usr/lib/jvm/java')
      end
    end

    context 'default_java_symlink' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(
          file_cache_path: '/var/chef/cache', platform: 'debian', version: '8.0').converge(described_recipe)
      end

      it 'symlinks /usr/lib/jvm/default-java' do
        link = chef_run.link('/usr/lib/jvm/default-java')
        expect(link).to link_to('/usr/lib/jvm/java')
      end
    end
  end
end
