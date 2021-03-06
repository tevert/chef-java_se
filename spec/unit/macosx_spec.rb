require 'spec_helper'
require 'mixlib/shellout'

describe 'java_se::default' do
  context 'mac_os_x' do
    let(:shellout) { double(exitstatus: 1, run_command: nil, error!: nil, stdout: '') }

    let(:chef_run) do
      ChefSpec::SoloRunner.new(file_cache_path: '/var/chef/cache', platform: 'mac_os_x', version: '10.10') do
        allow(Mixlib::ShellOut).to receive(:new).and_return(shellout)
      end.converge(described_recipe)
    end

    it 'installs open_uri_redirections gem' do
      expect(chef_run).to install_chef_gem('open_uri_redirections')
    end

    it 'fetches java' do
      expect(chef_run).to run_ruby_block(
        'fetch http://download.oracle.com/otn-pub/java/jdk/8u60-b27/jdk-8u60-macosx-x64.dmg')
    end

    it 'validates java' do
      expect(chef_run).to run_ruby_block('validate /var/chef/cache/jdk-8u60-macosx-x64.dmg')
    end

    it 'attaches volume' do
      expect(chef_run).to run_execute("hdiutil attach '/var/chef/cache/jdk-8u60-macosx-x64.dmg' -quiet")
    end

    it 'install pkg' do
      expect(chef_run).to run_execute("sudo installer -pkg '/Volumes/JDK 8 Update 60/JDK 8 Update 60.pkg' -target /")
    end

    it 'detaches volume' do
      expect(chef_run).to run_execute("hdiutil detach '/Volumes/JDK 8 Update 60' " \
        "|| hdiutil detach '/Volumes/JDK 8 Update 60' -force")
    end

    it 'adds BundledApp capability' do
      expect(chef_run).to run_execute('/usr/bin/sudo /usr/libexec/PlistBuddy -c ' \
        "\"Add :JavaVM:JVMCapabilities: string BundledApp\" " \
        '/Library/Java/JavaVirtualMachines/jdk1.8.0_60.jdk/Contents/Info.plist')
    end

    it 'adds JNI capability' do
      expect(chef_run).to run_execute('/usr/bin/sudo /usr/libexec/PlistBuddy -c ' \
        "\"Add :JavaVM:JVMCapabilities: string JNI\" " \
        '/Library/Java/JavaVirtualMachines/jdk1.8.0_60.jdk/Contents/Info.plist')
    end

    it 'adds WebStart capability' do
      expect(chef_run).to run_execute('/usr/bin/sudo /usr/libexec/PlistBuddy -c ' \
        "\"Add :JavaVM:JVMCapabilities: string WebStart\" " \
        '/Library/Java/JavaVirtualMachines/jdk1.8.0_60.jdk/Contents/Info.plist')
    end

    it 'adds Applets capability' do
      expect(chef_run).to run_execute('/usr/bin/sudo /usr/libexec/PlistBuddy -c ' \
        "\"Add :JavaVM:JVMCapabilities: string Applets\" " \
        '/Library/Java/JavaVirtualMachines/jdk1.8.0_60.jdk/Contents/Info.plist')
    end

    it 'removes previous jdk' do
      expect(chef_run).to run_execute('/usr/bin/sudo /bin/rm -rf ' \
        '/System/Library/Frameworks/JavaVM.framework/Versions/CurrentJDK')
    end

    it 'adds current jdk' do
      expect(chef_run).to run_execute('/usr/bin/sudo /bin/ln -nsf ' \
        '/Library/Java/JavaVirtualMachines/jdk1.8.0_60.jdk/Contents ' \
        '/System/Library/Frameworks/JavaVM.framework/Versions/CurrentJDK')
    end

    it 'creates java home' do
      expect(chef_run).to run_execute('/usr/bin/sudo /bin/ln -nsf ' \
        '/Library/Java/JavaVirtualMachines/jdk1.8.0_60.jdk/Contents/Home /Library/Java/Home')
    end

    it 'creates lib dir' do
      expect(chef_run).to run_execute('/usr/bin/sudo /bin/mkdir -p ' \
        '/Library/Java/JavaVirtualMachines/jdk1.8.0_60.jdk/Contents/Home/bundle/Libraries')
    end

    it 'creates java home' do
      expect(chef_run).to run_execute('/usr/bin/sudo /bin/ln -nsf ' \
        '/Library/Java/JavaVirtualMachines/jdk1.8.0_60.jdk/Contents/Home/jre/lib/server/libjvm.dylib ' \
        '/Library/Java/JavaVirtualMachines/jdk1.8.0_60.jdk/Contents/Home/bundle/Libraries/libserver.dylib')
    end
  end
end
