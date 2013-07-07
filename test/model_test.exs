Code.require_file "test_helper.exs", __DIR__

defrecord Atlas.ModelTest.TestRecord, name: nil, total: nil
defmodule Atlas.ModelTest.TestModule do
  use Atlas.Model

  validates_presence_of :name
  validates_length_of :name, greater_than: 2, less_than: 6
end

defmodule Atlas.ModelTest.Fixtures do
  alias Atlas.ModelTest.TestRecord

  def valid_record,   do: TestRecord.new(name: "Chris")
  def invalid_record, do: TestRecord.new(name: "Name Too Long")
end

defmodule Atlas.ModelTest do
  use ExUnit.Case
  import Atlas.ModelTest.Fixtures
  alias Atlas.ModelTest.TestModule
  alias Atlas.ModelTest.TestRecord


  test "it adds validations to the module" do
    assert TestModule.validations == [
      {:length_of,:name,[greater_than: 2, less_than: 6]},
      {:presence_of,:name,[]}
    ]
  end

  test "#validate returns {:ok, record} when all validations return no errors" do
    assert TestModule.validate(valid_record) == { :ok, valid_record }
  end

  test "#validate returns {:error, reasons} when validations return errors" do
    assert TestModule.validate(invalid_record) == { 
      :error, ["name must be greater than 2 and less than 6 characters"] 
    }
  end

  test "#valid? returns true when validations return no errors" do
    assert TestModule.valid?(valid_record)
  end

  test "#valid? returns false when validations return any errors" do
    refute TestModule.valid?(invalid_record)
  end

  test "#validates_length_of with greather_than" do
    defmodule LengthOf do
      use Atlas.Model
      validates_length_of :name, greater_than: 2
    end
    errors = LengthOf.errors(TestRecord.new name: "DJ")

    assert Enum.member? errors, "name must be greater than 2 characters"
    assert LengthOf.valid?(TestRecord.new name: "DJ DUBS")
  end

  test "#validates_length_of with greather_than_or_equal" do
    defmodule LengthOf1 do
      use Atlas.Model
      validates_length_of :name, greater_than_or_equal: 3
    end
    errors = LengthOf1.errors(TestRecord.new name: "DJ")

    assert Enum.member? errors, "name must be greater than or equal to 3 characters"
    assert LengthOf1.valid?(TestRecord.new name: "DJ DUBS")
  end

  test "#validates_length_of with greather_than and less_than" do
    defmodule LengthOf2 do
      use Atlas.Model
      validates_length_of :name, greater_than: 2, less_than: 10
    end
    errors = LengthOf2.errors(TestRecord.new name: "DJ")

    assert Enum.member? errors, "name must be greater than 2 and less than 10 characters"
    assert LengthOf2.valid?(TestRecord.new name: "DJ DUBS")
    refute LengthOf2.valid?(TestRecord.new name: "DJ DUBS TOO LONG")
  end

  test "#validates_length_of with greather_than and less_than_or_equal" do
    defmodule LengthOf3 do
      use Atlas.Model
      validates_length_of :name, greater_than: 2, less_than_or_equal: 10
    end
    errors = LengthOf3.errors(TestRecord.new name: "DJ")

    assert Enum.member? errors, "name must be greater than 2 and less than or equal to 10 characters"
    assert LengthOf3.valid?(TestRecord.new name: "DJ DUBS")
    refute LengthOf3.valid?(TestRecord.new name: "DJ DUBS TOO LONG")
  end

  test "#validates_presence_of" do
    defmodule PresenceOf do
      use Atlas.Model
      validates_presence_of :name
    end
    errors = PresenceOf.errors(TestRecord.new name: nil)

    assert Enum.first(errors) == "name must not be blank"
    assert PresenceOf.valid?(TestRecord.new name: "Chris")
    refute PresenceOf.valid?(TestRecord.new name: nil)
  end

  test "#validates_numericality_of" do
    defmodule NumericalityOf do
      use Atlas.Model
      validates_numericality_of :total
    end
    errors = NumericalityOf.errors(TestRecord.new total: "bogus")

    assert Enum.first(errors) == "total must be a valid number"
    assert NumericalityOf.valid?(TestRecord.new total: "1234")
    assert NumericalityOf.valid?(TestRecord.new total: "-12.34")
    refute NumericalityOf.valid?(TestRecord.new total: "")
    assert NumericalityOf.valid?(TestRecord.new total: 1234)
    assert NumericalityOf.valid?(TestRecord.new total: -12.34)
    refute NumericalityOf.valid?(TestRecord.new total: nil)
    refute NumericalityOf.valid?(TestRecord.new total: [])
    refute NumericalityOf.valid?(TestRecord.new total: true)
  end
end
