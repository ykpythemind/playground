require "minitest/autorun"
require "bundler/setup"

require "interval_set"

class Test < Minitest::Test
  def test_interval
    set = IntervalSet[Time.new(2010, 1, 3, 10)..Time.new(2010, 1, 6, 8)]

    assert set.include?(Time.new(2010, 1, 4, 10))
    assert set.include?(Time.new(2010, 1, 6, 7, 59, 59))
    assert !set.include?(Time.new(2010, 1, 6, 8))
    assert !set.include?(Time.new(2020, 3, 6, 8))
  end

  def test_intersection
    set_a = IntervalSet[Time.new(2020, 1, 1, 10)..Time.new(2020, 1, 30, 8)]
    set_b = IntervalSet[Time.new(2020, 1, 3, 10)..Time.new(2020, 1, 6, 2)]
    set_c = IntervalSet[Time.new(2020, 1, 4, 22)..Time.new(2020, 1, 12, 10)]

    # 1/1.10(a) ... 1/3.10(b) ... 1/4.22(c) .... 1/6.2(b) ... 1/12.10(c) ... 1/30.8(a)

    res = set_a & set_b & set_c

    assert res == IntervalSet[Time.new(2020, 1, 4, 22)..Time.new(2020, 1, 6, 2)]

    res2 = set_a & IntervalSet[]
    assert res2 == IntervalSet[]
  end
end

class AvailableTimeBuilder
end

class ShopAvailableTimeBuilder
  def initialize() # hogehoge
  end

  # 計算を省略してサンプルを返却
  def call
    IntervalSet[Time.new(2020, 1, 1)..Time.new(2020, 1, 31), Time.new(2020, 2, 1)..Time.new(2020, 2, 28)]
  end
end

class StaffBlockedHourTimeBuilder
  def initialize()
  end

  def call
    IntervalSet[Time.new(2020, 1, 5, 12)..Time.new(2020, 1, 5, 16)]
  end
end

class Test2 < Minitest::Test
  def test_sample_impl
    builders = [ShopAvailableTimeBuilder.new, StaffBlockedHourTimeBuilder.new]

    result_set = builders.map(&:call).reduce(&:intersection)

    assert result_set == IntervalSet[Time.new(2020, 1, 5, 12)..Time.new(2020, 1, 5, 16)]
  end
end
