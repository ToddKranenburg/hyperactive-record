require 'sql_base'
require 'db_connection'
require 'securerandom'

describe SQLBase do
  before(:each) {DBConnection.reset}
  after(:each) {DBConnection.reset}

  context 'before ::finalize!' do
    before(:each) do
      class Plant < SQLBase
      end
    end

    after(:each) do
      Object.send(:remove_const, :Plant)
    end

    describe '::table_name' do
      it 'generates default name' do
        expect(Plant.table_name).to eq('plants')
      end
    end

    describe '::table_name=' do
      it 'sets table name' do
        class Human < SQLBase
          self.table_name = 'humans'
        end

        expect(Human.table_name).to eq('humans')

        Object.send(:remove_const, :Human)
      end
    end

    describe '::columns' do
      it 'returns a list of all column names as symbols' do
        expect(Plant.columns).to eq([:id, :name, :owner_id])
      end

      it 'only queries the DB once' do
        expect(DBConnection).to(
          receive(:execute2).exactly(1).times.and_call_original)
        3.times { Plant.columns }
      end
    end

    describe '#attributes' do
      it 'returns @attributes hash byref' do
        plant_attributes = {name: 'Leafiery'}
        c = Plant.new
        c.instance_variable_set('@attributes', plant_attributes)

        expect(c.attributes).to equal(plant_attributes)
      end

      it 'lazily initializes @attributes to an empty hash' do
        c = Plant.new

        expect(c.instance_variables).not_to include(:@attributes)
        expect(c.attributes).to eq({})
        expect(c.instance_variables).to include(:@attributes)
      end
    end
  end

  context 'after ::finalize!' do
    before(:all) do
      class Plant < SQLBase
        self.finalize!
      end

      class Human < SQLBase
        self.table_name = 'humans'

        self.finalize!
      end
    end

    after(:all) do
      Object.send(:remove_const, :Plant)
      Object.send(:remove_const, :Human)
    end

    describe '::finalize!' do
      it 'creates getter methods for each column' do
        c = Plant.new
        expect(c.respond_to? :something).to be false
        expect(c.respond_to? :name).to be true
        expect(c.respond_to? :id).to be true
        expect(c.respond_to? :owner_id).to be true
      end

      it 'creates setter methods for each column' do
        c = Plant.new
        c.name = "Nick Diaz"
        c.id = 209
        c.owner_id = 2
        expect(c.name).to eq 'Nick Diaz'
        expect(c.id).to eq 209
        expect(c.owner_id).to eq 2
      end
      #
      it 'created getter methods read from attributes hash' do
        c = Plant.new
        c.instance_variable_set(:@attributes, {name: "Nick Diaz"})
        expect(c.name).to eq 'Nick Diaz'
      end

      it 'created setter methods use attributes hash to store data' do
        c = Plant.new
        c.name = "Nick Diaz"

        expect(c.instance_variables).to include(:@attributes)
        expect(c.instance_variables).not_to include(:@name)
        expect(c.attributes[:name]).to eq 'Nick Diaz'
      end

      describe '#initialize' do
        it 'calls appropriate setter method for each item in params' do
          # We have to set method expectations on the plant object *before*
          # #initialize gets called, so we use ::allocate to create a
          # blank Plant object first and then call #initialize manually.
          c = Plant.allocate

          expect(c).to receive(:name=).with('Don Frye')
          expect(c).to receive(:id=).with(100)
          expect(c).to receive(:owner_id=).with(4)

          c.send(:initialize, {name: 'Don Frye', id: 100, owner_id: 4})
        end

        it 'throws an error when given an unknown attribute' do
          expect do
            Plant.new(favorite_band: 'Anybody but The Eagles')
          end.to raise_error "unknown attribute 'favorite_band'"
        end
      end

      describe '::all, ::parse_all' do
        it '::all returns all the rows' do
          plants = Plant.all
          expect(plants.count).to eq(5)
        end

        it '::parse_all turns an array of hashes into objects' do
          hashes = [
            { name: 'plant1', owner_id: 1 },
            { name: 'plant2', owner_id: 2 }
          ]

          plants = Plant.parse_all(hashes)
          expect(plants.length).to eq(2)
          hashes.each_index do |i|
            expect(plants[i].name).to eq(hashes[i][:name])
            expect(plants[i].owner_id).to eq(hashes[i][:owner_id])
          end
        end

        it '::all returns a list of objects, not hashes' do
          plants = Plant.all
          plants.each { |plant| expect(plant).to be_instance_of(Plant) }
        end
      end

      describe '::find' do
        it 'fetches single objects by id' do
          c = Plant.find(1)

          expect(c).to be_instance_of(Plant)
          expect(c.id).to eq(1)
        end

        it 'returns nil if no object has the given id' do
          expect(Plant.find(123)).to be_nil
        end
      end

      describe '#attribute_values' do
        it 'returns array of values' do
          plant = Plant.new(id: 123, name: 'plant1', owner_id: 1)

          expect(plant.attribute_values).to eq([123, 'plant1', 1])
        end
      end

      describe '#insert' do
        let(:plant) { Plant.new(name: 'Gizmo', owner_id: 1) }

        before(:each) { plant.insert }

        it 'inserts a new record' do
          expect(Plant.all.count).to eq(6)
        end

        it 'sets the id once the new record is saved' do
          expect(plant.id).to eq(DBConnection.last_insert_row_id)
        end

        it 'creates a new record with the correct values' do
          # pull the plant again
          plant2 = Plant.find(plant.id)

          expect(plant2.name).to eq('Gizmo')
          expect(plant2.owner_id).to eq(1)
        end
      end

      describe '#update' do
        it 'saves updated attributes to the DB' do
          human = Human.find(2)

          human.fname = 'Matthew'
          human.lname = 'von Rubens'
          human.update

          # pull the human again
          human = Human.find(2)
          expect(human.fname).to eq('Matthew')
          expect(human.lname).to eq('von Rubens')
        end
      end

      describe '#save' do
        it 'calls #insert when record does not exist' do
          human = Human.new
          expect(human).to receive(:insert)
          human.save
        end

        it 'calls #update when record already exists' do
          human = Human.find(1)
          expect(human).to receive(:update)
          human.save
        end
      end

    end
  end
end
