require 'associatable'

describe 'AssocOptions' do
  describe 'BelongsToOptions' do
    it 'provides defaults' do
      options = BelongsToOptions.new('house')

      expect(options.foreign_key).to eq(:house_id)
      expect(options.class_name).to eq('House')
      expect(options.primary_key).to eq(:id)
    end

    it 'allows overrides' do
      options = BelongsToOptions.new('owner',
                                     foreign_key: :human_id,
                                     class_name: 'Human',
                                     primary_key: :human_id
      )

      expect(options.foreign_key).to eq(:human_id)
      expect(options.class_name).to eq('Human')
      expect(options.primary_key).to eq(:human_id)
    end
  end

  describe 'HasManyOptions' do
    it 'provides defaults' do
      options = HasManyOptions.new('plants', 'Human')

      expect(options.foreign_key).to eq(:human_id)
      expect(options.class_name).to eq('Plant')
      expect(options.primary_key).to eq(:id)
    end

    it 'allows overrides' do
      options = HasManyOptions.new('plants', 'Human',
                                   foreign_key: :owner_id,
                                   class_name: 'Kitten',
                                   primary_key: :human_id
      )

      expect(options.foreign_key).to eq(:owner_id)
      expect(options.class_name).to eq('Kitten')
      expect(options.primary_key).to eq(:human_id)
    end
  end

  describe 'AssocOptions' do
    before(:all) do
      class Plant < SQLBase
        self.finalize!
      end

      class Human < SQLBase
        self.table_name = 'humans'

        self.finalize!
      end
    end

    it '#model_class returns class of associated object' do
      options = BelongsToOptions.new('human')
      expect(options.model_class).to eq(Human)

      options = HasManyOptions.new('plants', 'Human')
      expect(options.model_class).to eq(Plant)
    end

    it '#table_name returns table name of associated object' do
      options = BelongsToOptions.new('human')
      expect(options.table_name).to eq('humans')

      options = HasManyOptions.new('plants', 'Human')
      expect(options.table_name).to eq('plants')
    end
  end
end

describe 'Associatable' do
  before(:each) { DBConnection.reset }
  after(:each) { DBConnection.reset }

  before(:all) do
    class Plant < SQLBase
      belongs_to :human, foreign_key: :owner_id

      finalize!
    end

    class Human < SQLBase
      self.table_name = 'humans'

      has_many :plants, foreign_key: :owner_id
      belongs_to :house

      finalize!
    end

    class House < SQLBase
      has_many :humans

      finalize!
    end
  end

  describe '#belongs_to' do
    let(:thirsty) { Plant.find(1) }
    let(:katharine) { Human.find(1) }

    it 'fetches `human` from `Plant` correctly' do
      expect(thirsty).to respond_to(:human)
      human = thirsty.human

      expect(human).to be_instance_of(Human)
      expect(human.fname).to eq('Katharine')
    end

    it 'fetches `house` from `Human` correctly' do
      expect(katharine).to respond_to(:house)
      house = katharine.house

      expect(house).to be_instance_of(House)
      expect(house.address).to eq('323 South 5th St')
    end

    it 'returns nil if no associated object' do
      stray_plant = Plant.find(5)
      expect(stray_plant.human).to eq(nil)
    end
  end

  describe '#has_many' do
    let(:pam) { Human.find(3) }
    let(:pam_house) { House.find(2) }

    it 'fetches `plants` from `Human`' do
      expect(pam).to respond_to(:plants)
      plants = pam.plants

      expect(plants.length).to eq(2)

      expected_plant_names = %w(Stalky Droopy)
      2.times do |i|
        plant = plants[i]

        expect(plant).to be_instance_of(Plant)
        expect(plant.name).to eq(expected_plant_names[i])
      end
    end

    it 'fetches `humans` from `House`' do
      expect(pam_house).to respond_to(:humans)
      humans = pam_house.humans

      expect(humans.length).to eq(1)
      expect(humans[0]).to be_instance_of(Human)
      expect(humans[0].fname).to eq('Pam')
    end

    it 'returns an empty array if no associated items' do
      plantless_human = Human.find(4)
      expect(plantless_human.plants).to eq([])
    end
  end

  describe '::assoc_options' do
    it 'defaults to empty hash' do
      class TempClass < SQLBase
      end

      expect(TempClass.assoc_options).to eq({})
    end

    it 'stores `belongs_to` options' do
      plant_assoc_options = Plant.assoc_options
      human_options = plant_assoc_options[:human]

      expect(human_options).to be_instance_of(BelongsToOptions)
      expect(human_options.foreign_key).to eq(:owner_id)
      expect(human_options.class_name).to eq('Human')
      expect(human_options.primary_key).to eq(:id)
    end

    it 'stores options separately for each class' do
      expect(Plant.assoc_options).to have_key(:human)
      expect(Human.assoc_options).to_not have_key(:human)

      expect(Human.assoc_options).to have_key(:house)
      expect(Plant.assoc_options).to_not have_key(:house)
    end
  end

  describe '#has_one_through' do
    before(:all) do
      class Plant
        has_one_through :home, :human, :house

        self.finalize!
      end
    end

    let(:plant) { Plant.find(1) }

    it 'adds getter method' do
      expect(plant).to respond_to(:home)
    end

    it 'fetches associated `home` for a `Plant`' do
      house = plant.home

      expect(house).to be_instance_of(House)
      expect(house.address).to eq('323 South 5th St')
    end
  end

  describe '#has_many_through' do
    before(:all) do
      class House
        has_many_through :plants, :humans, :plants

        self.finalize!
      end
    end

    let(:house) { House.find(1) }

    it 'adds getter method' do
      expect(house).to respond_to(:plants)
    end

    it 'fetches associated `plants` for a `House`' do
      plants = house.plants

      expect(plants.length).to eq(2)
      expect(plants.first.name).to eq('Thirsty')
      expect(plants.last.name).to eq('Leafy')
    end
  end
end
