require 'spec_helper'

describe LicenseFinder do
  describe ".config" do
    let(:config) do
      {
        'whitelist' => %w(MIT Apache),
        'ignore_groups' => %w(test development)
      }
    end

    before do
      stub(File).exists?('./config/license_finder.yml') { true }
      stub(File).open('./config/license_finder.yml').stub!.readlines.stub!.join { config.to_yaml }
    end

    after do
      LicenseFinder.instance_variable_set(:@config, nil)
    end

    it "should handle a missing configuration file" do
      stub(File).exists?('./config/license_finder.yml') { false }
      dont_allow(File).open('./config/license_finder.yml')

      LicenseFinder.config.whitelist.should == []
      LicenseFinder.config.ignore_groups.should == []
      LicenseFinder.config.dependencies_dir.should == '.'
    end

    it "should load the configuration exactly once" do
      mock(File).open('./config/license_finder.yml').stub!.readlines.stub!.join { config.to_yaml }

      LicenseFinder.config.whitelist

      dont_allow(File).open('./config/license_finder.yml')

      LicenseFinder.config.whitelist
    end

    describe "#whitelist" do
      it "should load a whitelist from license_finder.yml" do
        LicenseFinder.config.whitelist.should =~ %w(MIT Apache)
      end

      it "should load an empty whitelist from license_finder.yml when there are no whitelist items" do
        stub(File).open('./config/license_finder.yml').stub!.readlines.stub!.join { config.merge('whitelist' => nil).to_yaml }

        LicenseFinder.config.whitelist.should =~ []
      end
    end

    describe "#ignore_groups" do
      it "should load a ignore_groups list from license_finder.yml" do
        LicenseFinder.config.ignore_groups.should == [:test, :development]
      end

      it "should load an empty ignore_groups list from license_finder.yml when there are no ignore groups" do
        stub(File).open('./config/license_finder.yml').stub!.readlines.stub!.join { config.merge('ignore_groups' => nil).to_yaml }

        LicenseFinder.config.ignore_groups.should == []
      end
    end

    describe "#dependencies_dir" do
      it 'should allow the dependencies file directory to be configured' do
        stub(File).open('./config/license_finder.yml').stub!.readlines.stub!.join { config.merge('dependencies_file_dir' => './elsewhere').to_yaml }

        config = LicenseFinder.config
        config.dependencies_dir.should == './elsewhere'
        config.dependencies_yaml.should == './elsewhere/dependencies.yml'
        config.dependencies_text.should == './elsewhere/dependencies.txt'
      end

      it 'should default the dependency files when the directory is not provided' do
        config = LicenseFinder.config
        config.dependencies_dir.should == '.'
        config.dependencies_yaml.should == './dependencies.yml'
        config.dependencies_text.should == './dependencies.txt'
      end
    end
  end
end