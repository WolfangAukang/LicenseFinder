require 'spec_helper'
require 'fakefs/spec_helpers'

module LicenseFinder
  describe Dep do
    it_behaves_like 'a PackageManager'
    describe '#current_packages' do
      subject { Dep.new(project_path: Pathname('/app'), logger: double(:logger, active: nil)) }

      it 'returns the packages described by Gopkg.lock' do
        FakeFS do
          FileUtils.mkdir_p '/app'
          File.write('/app/Gopkg.lock',
                     '
                     # This file is autogenerated, do not edit; changes may be undone by the next \'dep ensure\'.


[[projects]]
  name = "github.com/Bowery/prompt"
  packages = ["."]
  revision = "0f1139e9a1c74b57ccce6bdb3cd2f7cd04dd3449"

[[projects]]
  name = "github.com/dchest/safefile"
  packages = ["."]
  revision = "855e8d98f1852d48dde521e0522408d1fe7e836a"

[[projects]]
  branch = "master"
  name = "golang.org/x/sys"
  packages = ["unix"]
  revision = "ebfc5b4631820b793c9010c87fd8fef0f39eb082"

[solve-meta]
  analyzer-name = "dep"
  analyzer-version = 1
  inputs-digest = "86b83c814eafcfe22dc5466976859ae59ff8191c77f439410547fb6b15ead41c"
  solver-name = "gps-cdcl"
  solver-version = 1
          ')

          expect(subject.current_packages.length).to eq 3

          expect(subject.current_packages.first.name).to eq 'github.com/Bowery/prompt'
          expect(subject.current_packages.first.version).to eq '0f1139e9a1c74b57ccce6bdb3cd2f7cd04dd3449'

          expect(subject.current_packages[1].name).to eq 'github.com/dchest/safefile'
          expect(subject.current_packages[1].version).to eq '855e8d98f1852d48dde521e0522408d1fe7e836a'

          expect(subject.current_packages.last.name).to eq 'golang.org/x/sys'
          expect(subject.current_packages.last.version).to eq 'ebfc5b4631820b793c9010c87fd8fef0f39eb082'
        end
      end
    end

    describe '.prepare_command' do
      it 'returns the correct prepare method' do
        expect(described_class.prepare_command).to eq('dep ensure')
      end
    end

    describe '.package_management_command' do
      it 'returns the correct package management command' do
        expect(described_class.package_management_command).to eq('dep')
      end
    end
  end
end
