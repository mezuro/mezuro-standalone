require 'rails_helper'

describe KalibroConfiguration, :type => :model do
  describe 'methods' do

    describe 'class methods' do
      describe 'public_or_owned_by_user' do
        def build_attrs(kc_iter, *traits, **params)
          kalibro_configuration = kc_iter.next
          attr = FactoryGirl.build(:kalibro_configuration_attributes, *traits, params.merge(kalibro_configuration: kalibro_configuration))
          kalibro_configuration.stubs(:attributes).returns(attr)
          attr
        end

        let!(:kalibro_configurations) { FactoryGirl.build_list(:kalibro_configuration, 4, :with_sequential_id) }
        let!(:kc_iter) { kalibro_configurations.each }

        let!(:one_user) { FactoryGirl.build(:user) }
        let!(:other_user) { FactoryGirl.build(:another_user) }

        let!(:ones_private_attrs) { build_attrs(kc_iter, :private, user: one_user) }
        let!(:others_private_attrs) { build_attrs(kc_iter, :private, user: other_user) }
        let!(:ones_public_attrs) { build_attrs(kc_iter, user: one_user) }
        let!(:others_public_attrs) { build_attrs(kc_iter, user: other_user) }

        let!(:public_attrs) { [ones_public_attrs, others_public_attrs] }
        let(:public_kalibro_configurations) { public_attrs.map(&:kalibro_configuration) }

        let(:ones_or_public_attrs) { public_attrs + [ones_private_attrs] }
        let(:ones_or_public_kalibro_configurations) { ones_or_public_attrs.map(&:kalibro_configuration) }

        before :each do
          # Map the reading group attributes to the corresponding Reading Group
          kalibro_configurations.each do |kc|
            KalibroConfiguration.stubs(:find).with(kc.id).returns(kc)
          end
        end

        context 'when user is not provided' do
          before do
            KalibroConfigurationAttributes.expects(:where).with(public: true).returns(public_attrs)
          end

          it 'should find all public reading groups' do
            expect(KalibroConfiguration.public).to eq(public_kalibro_configurations)
          end
        end

        context 'when user is provided' do
          before do
            KalibroConfigurationAttributes.expects(:where).with(kind_of(String), one_user.id).returns(ones_or_public_attrs)
          end

          it 'should find all public and owned reading groups' do
            expect(KalibroConfiguration.public_or_owned_by_user(one_user)).to eq(ones_or_public_kalibro_configurations)
          end
        end
      end
    end
  end
end