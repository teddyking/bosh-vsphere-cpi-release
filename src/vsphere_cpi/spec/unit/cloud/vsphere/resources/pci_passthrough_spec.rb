require 'spec_helper'

describe VSphereCloud::Resources::PCIPassthrough do
  describe '#create_pci_passthrough' do
    let(:device_id) { 'some-device' }
    let(:vendor_id) { 'some-vendor' }
    it 'creates a PCI Passthrough device' do
      spec = described_class.create_pci_passthrough(vendor_id:, device_id:)
      expect(spec.backing.allowed_device.length).to eq(1)
      expect(spec.backing.allowed_device.first.device_id).to eq('some-device')
      expect(spec.backing.allowed_device.first.vendor_id).to eq('some-vendor')
    end
  end
  describe '#create_vgpu' do
    let(:vgpu) { 'fake-vgpu-name' }
    it 'creates a vgpu' do
      spec = described_class.create_vgpu(vgpu)
      expect(spec.backing.vgpu).to eq(vgpu)
      expect(spec.key).to eq(-1)
    end
    context 'with multiple vgpus' do
      it 'should create a unique key for each vgpu' do
        used_keys = []
        (0..15).each do |i|
          spec = described_class.create_vgpu(vgpu)
          expect(spec.backing.vgpu).to eq(vgpu)
          expect(used_keys.size).to eq(i)
          expect(used_keys.include?(spec.key)).to be_falsey
          used_keys << spec.key
        end
      end
    end
  end

  describe '#create_device_group' do
    let(:device_group_name) { 'nvlink-gpu-group-1' }

    it 'creates a device group' do
      device_group = described_class.create_device_group(device_group_name)
      expect(device_group.device_group_name).to eq(device_group_name)
      expect(device_group.group_instance_key).to eq(1)
    end

    context 'with multiple device groups' do
      it 'should create a unique group_instance_key for each device group' do
        used_keys = []
        device_groups = ['group-1', 'group-2', 'group-3']

        device_groups.each_with_index do |group_name, i|
          device_group = described_class.create_device_group(group_name)
          expect(device_group.device_group_name).to eq(group_name)
          expect(used_keys.size).to eq(i)
          expect(used_keys.include?(device_group.group_instance_key)).to be_falsey
          used_keys << device_group.group_instance_key
        end
      end
    end
  end
end
