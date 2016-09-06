require_relative "../../test_helper"
require_relative "flow_test_helper"

require "smart_answer_flows/simplified-expenses-checker"

class SimplifiedExpensesCheckerTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow SmartAnswer::SimplifiedExpensesCheckerFlow
  end

  context "you can't use simplified expenses result (Q1, Q2, result 1)" do
    context "none of these expense" do
      setup do
        add_response ""
      end

      should "take you to result 1 - you can't use" do
        assert_current_node :you_cant_use_result
      end
    end
    context "none of these expenses" do
      setup do
        add_response ""
      end

      should "take you to result 1 - you can't use" do
        assert_current_node :you_cant_use_result
      end
    end
  end # end tests for "you can't use simplified expenses"

  context "capital allowances claimed result (Q1, Q2, Q3, result 3)" do
    context "car, not buying a new vehicle this year" do
      setup do
        add_response "car"
        add_response "no"
        add_response "capital_allowance_claimed"
      end

      should "take you to result 3 - can't use as previously claimed Capital Allowance" do
        assert_current_node :capital_allowance_result
      end
    end
    context "motorbike, not buying a new vehicle this year" do
      setup do
        add_response "motorbike"
        add_response "no"
        add_response "capital_allowance_claimed"
      end

      should "take you to result 3 - can't use as previously claimed Capital Allowance" do
        assert_current_node :capital_allowance_result
      end
    end
    context "car, van & motorbike, not buying a new vehicle this year" do
      setup do
        add_response "car,van,motorbike"
        add_response "no"
        add_response "capital_allowance_claimed"
      end

      should "take you to result 3 - can't use as previously claimed Capital Allowance" do
        assert_current_node :capital_allowance_result
      end
    end
    context "claimed expenses before, using_home_for_business and live_on_business_premises" do
      setup do
        add_response "yes"
        add_response "live_on_business_premises,motorcycle,using_home_for_business"
      end

      should "raise invalid error" do
        assert_current_node :type_of_expense?, error: true
      end
    end
  end # end tests for "can't claim because previously claimed Capital Allowance"

  context "main result, car only" do
    setup do
      add_response "car"
    end

    context "new green car costs 1000, expect to drive 2000 miles, (Q2, Q5, Q9, you_can_use_result)" do
      setup do
        add_response "new"
        add_response "1000" #how_much_expect_to_claim
        add_response "low" #emissions
        add_response "10000" #green_vehicle_price
        add_response "80" #green_vehicle_write_off
        add_response "2000" #drive_business_miles_car_van
      end

      should "take you to you_can_use_result - main result" do
        assert_current_node :you_can_use_result
        assert_state_variable :vehicle_filthiness, "green"
        assert_state_variable :green_vehicle_price, 10000
        assert_state_variable :green_vehicle_write_off, 8000
        assert_state_variable :simple_vehicle_costs, 900
        assert_state_variable :current_scheme_costs, 9000
        assert_state_variable :simple_total, 900
        assert_state_variable :can_use_simple, false
      end
    end

    context "used car costs 1000, expect to drive 2000 miles, (Q2, Q5, Q9, you_can_use_result)" do
      setup do
        add_response "used"
        add_response "1000" #how_much_expect_to_claim
        add_response "medium" #emissions
        add_response "10000" #dirty_vehicle_price
        add_response "80" #dirty_vehicle_write_off
        add_response "2000" #simple_vehicle_costs
      end


      should "take you to you_can_use_result - main result" do
        assert_current_node :you_can_use_result
        assert_state_variable :vehicle_filthiness, "dirty"
        assert_state_variable :dirty_vehicle_price, 1800
        assert_state_variable :dirty_vehicle_write_off, 1440
        assert_state_variable :simple_vehicle_costs, 900
        assert_state_variable :current_scheme_costs, 2440
        assert_state_variable :simple_total, 900
        assert_state_variable :can_use_simple, false
      end
    end

    context "used filthy car costs 1000, expect to drive 2000 miles, (Q2, Q5, Q9, you_can_use_result)" do
      setup do
        add_response "used"
        add_response "1000" #how_much_expect_to_claim
        add_response "high" #emissions
        add_response "10000" #dirty_vehicle_price
        add_response "80" #dirty_vehicle_write_off
        add_response "2000" #simple_vehicle_costs
      end


      should "take you to you_can_use_result - main result" do
        assert_current_node :you_can_use_result
        assert_state_variable :vehicle_filthiness, "filthy"
        assert_state_variable :filthy_vehicle_price, 800
        assert_state_variable :filthy_vehicle_write_off, 640
        assert_state_variable :simple_vehicle_costs, 900
        assert_state_variable :current_scheme_costs, 1640
        assert_state_variable :simple_total, 900
        assert_state_variable :can_use_simple, false
      end
    end

    context "no car costs 1000, not claimed Capital Allowance before, car is new at start of business, expect to drive 2000 miles, (Q2, Q3, Q4, Q5, Q9, you_can_use_result)" do
      setup do
        add_response "no"
        add_response "no"
        add_response "new"
        add_response "1000" #how_much_expect_to_claim
        add_response "2000" #drive_business_miles_car_van
      end

      should "take you to you_can_use_result - main result" do
        assert_current_node :you_can_use_result
        assert_state_variable :simple_vehicle_costs, 900
        assert_state_variable :current_scheme_costs, 1000
        assert_state_variable :simple_total, 900
        assert_state_variable :can_use_simple, false
      end
    end
  end

  context "main result, car only" do
    setup do
      add_response "car"
      add_response "no"
    end

    context "capital allowance" do
      should "take you to capital_allowance_result outcome" do
        add_response "capital_allowance_claimed"
        assert_current_node :capital_allowance_result
      end
    end

    context "simplified expense" do
      should "take you to you_can_use_result outcome" do
        add_response "simplified_expenses_claimed"
        add_response "1000" #how_much_expect_to_claim
        add_response "2000" #drive_business_miles_car_van
        assert_current_node :you_can_use_result
      end
    end

    context "none of the above" do
      should "take you to you_can_use_result" do
        add_response "no"
        add_response "new"
        add_response "1000" #how_much_expect_to_claim
        add_response "2000" #drive_business_miles_car_van
        assert_current_node :you_can_use_result
      end
    end
  end

  context "main result, van only" do
    setup do
      add_response "van"
      add_response "no"
    end

    context "capital allowance" do
      should "take you to capital_allowance_result outcome" do
        add_response "capital_allowance_claimed"
        assert_current_node :capital_allowance_result
      end
    end

    context "simplified expense" do
      should "take you to you_can_use_result outcome" do
        add_response "simplified_expenses_claimed"
        add_response "1000" #how_much_expect_to_claim
        add_response "2000" #drive_business_miles_car_van
        assert_current_node :you_can_use_result
      end
    end

    context "none of the above" do
      should "take you to you_can_use_result" do
        add_response "no"
        add_response "1000" #how_much_expect_to_claim
        add_response "10000" #dirty_vehicle_price
        add_response "80" #simple_vehicle_costs
        add_response "2000" #drive_business_miles_car_van

        assert_current_node :you_can_use_result
        assert_state_variable :simple_vehicle_costs, 900
        assert_state_variable :current_scheme_costs, 1000
        assert_state_variable :simple_total, 900
        assert_state_variable :can_use_simple, false
      end
    end
  end

  context "main result, motorbike only" do
    setup do
      add_response "motorbike"
      add_response "no"
    end

    context "capital allowance" do
      should "take you to capital_allowance_result outcome" do
        add_response "capital_allowance_claimed"
        assert_current_node :capital_allowance_result
      end
    end

    context "simplified expense" do
      should "take you to you_can_use_result outcome" do
        add_response "simplified_expenses_claimed"
        add_response "1000" #how_much_expect_to_claim
        add_response "2000" #drive_business_miles_car_van
        assert_current_node :you_can_use_result
      end
    end

    context "none of the above" do
      should "take you to you_can_use_result" do
        add_response "no"
        add_response "1000" #how_much_expect_to_claim
        add_response "10000" #dirty_vehicle_price
        add_response "80" #simple_vehicle_costs
        add_response "2000" #drive_business_miles_car_van

        assert_current_node :you_can_use_result
        assert_state_variable :current_scheme_costs, 1000
        assert_state_variable :simple_total, 480
        assert_state_variable :can_use_simple, false
      end
    end
  end

  context "main result, car only" do
    setup do
      add_response "car"
    end

    context "not buying new vehicle, not claimed Capital Allowance before, car is new at start of business, expect to claim 1000 pounds, expect to drive 2000 miles, (Q2, Q3, Q4, Q8, result 2)" do
      setup do
        add_response "no"
        add_response "no"
        add_response "new"
        add_response "1000" #vehicle_costs
        add_response "2000" #simple_vehicle_costs
      end

      should "take you to result 2 - main result" do
        assert_current_node :you_can_use_result
        assert_state_variable :vehicle_costs, 1000
        assert_state_variable :simple_vehicle_costs, 900
        assert_state_variable :current_scheme_costs, 1000
        assert_state_variable :simple_total, 900
        assert_state_variable :can_use_simple, false
      end
    end # no new vehicle

    context "new green vehicle costs 10000, 80% of time on business, expect to drive 2000 miles, (Q2, Q3, Q4, Q8, result 2)" do
      setup do
        add_response "new"
        add_response "1000" #how_much_expect_to_claim
        add_response "low" #emissions
        add_response "10000" #green_vehicle_price
        add_response "80" #green_vehicle_write_off
        add_response "2000" #simple_vehicle_costs
      end

      should "take you to result 2 - main result" do
        assert_current_node :you_can_use_result
        assert_state_variable :vehicle_filthiness, "green"
        assert_state_variable :green_vehicle_price, 10000
        assert_state_variable :green_vehicle_write_off, 8000
        assert_state_variable :simple_vehicle_costs, 900
        assert_state_variable :current_scheme_costs, 8000
        assert_state_variable :simple_total, 900
        assert_state_variable :can_use_simple, false
      end
    end # new green vehicle

    context "new filthy vehicle costs 10000, 80% of time on business, expect to drive 2000 miles, (Q2, Q3, Q4, Q8, result 2)" do
      setup do
        add_response "new"
        add_response "1000" #how_much_expect_to_claim
        add_response "high" #emissions
        add_response "10000" #dirty_vehicle_price
        add_response "80" #dirty_vehicle_write_off
        add_response "2000" #simple_vehicle_costs
      end

      should "take you to result 2 - main result" do
        assert_current_node :you_can_use_result
        assert_state_variable :vehicle_filthiness, "filthy"
        assert_state_variable :filthy_vehicle_price, 800
        assert_state_variable :filthy_vehicle_write_off, 640
        assert_state_variable :simple_vehicle_costs, 900
        assert_state_variable :current_scheme_costs, 1640
        assert_state_variable :simple_total, 900
        assert_state_variable :can_use_simple, false
      end
    end # new filthy vehicle

    context "new dirty vehicle costs 10000, 80% of time on business, expect to drive 2000 miles, (Q2, Q3, Q4, Q8, result 2)" do
      setup do
        add_response "new"
        add_response "1000" #how_much_expect_to_claim
        add_response "medium" #dirty
        add_response "10000" #dirty_vehicle_price
        add_response "80" #dirty_vehicle_write_off
        add_response "2000" #simple_vehicle_costs
      end

      should "take you to result 2 - main result" do
        assert_current_node :you_can_use_result
        assert_state_variable :vehicle_filthiness, "dirty"
        assert_state_variable :dirty_vehicle_price, 1800
        assert_state_variable :dirty_vehicle_write_off, 1440
        assert_state_variable :simple_vehicle_costs, 900
        assert_state_variable :current_scheme_costs, 2440
        assert_state_variable :simple_total, 900
        assert_state_variable :can_use_simple, false
      end
    end # new dirty vehicle
  end # end main result, existing business, car_or_van only

  context "home for business costs" do
    setup do
      add_response "using_home_for_business"
    end

    should "show the 'you can't use' outcome if hours worked is less than 25 hours" do
      add_response "20"
      assert_current_node :you_cant_use_result
    end

    should "show the costs bullet if home costs are > 0" do
      add_response "55"
      add_response "20"
      assert_current_node :you_can_use_result
    end
  end

  context "main result, car only" do
    setup do
      add_response "car"
    end
    context "not buying new vehicle, not claimed CA before, car is used at start of business, expect to claim 1000 pounds, expect to drive 2000 miles, (Q3, Q4, Q5, Q9, result 2)" do
      setup do
        add_response "no"
        add_response "no"
        add_response "used"
        add_response "1000" #vehicle_costs
        add_response "2000" #simple_vehicle_costs
      end

      should "take you to result 2 - main result" do
        assert_current_node :you_can_use_result
        assert_state_variable :vehicle_costs, 1000
        assert_state_variable :simple_vehicle_costs, 900
        assert_state_variable :current_scheme_costs, 1000
        assert_state_variable :simple_total, 900
        assert_state_variable :can_use_simple, false
      end
    end # no new vehicle

    context "new green vehicle costs 10000, 80% of time on business, expect to drive 2000 miles, (Q2, Q3, Q4, Q8, result 2)" do
      setup do
        add_response "new"
        add_response "1000" #how_much_expect_to_claim
        add_response "low" #emissions
        add_response "10000" #green_vehicle_price
        add_response "80" #green_vehicle_write_off
        add_response "2000" #simple_vehicle_costs
      end

      should "take you to result 2 - main result" do
        assert_current_node :you_can_use_result
        assert_state_variable :vehicle_filthiness, "green"
        assert_state_variable :green_vehicle_price, 10000
        assert_state_variable :green_vehicle_write_off, 8000
        assert_state_variable :simple_vehicle_costs, 900
        assert_state_variable :current_scheme_costs, 9000
        assert_state_variable :simple_total, 900
        assert_state_variable :can_use_simple, false
      end
    end # new green vehicle

    context "new dirty vehicle costs 10000, 80% of time on business, expect to drive 12000 miles, (Q2, Q3, Q4, Q8, result 2)" do
      setup do
        add_response "new"
        add_response "1000" #how_much_expect_to_claim
        add_response "medium" #dirty
        add_response "10000" #dirty_vehicle_price
        add_response "80" #dirty_vehicle_write_off
        add_response "12000" #simple_vehicle_costs
      end

      should "take you to result 2 - main result" do
        assert_current_node :you_can_use_result
        assert_state_variable :vehicle_filthiness, "dirty"
        assert_state_variable :dirty_vehicle_price, 1800
        assert_state_variable :dirty_vehicle_write_off, 1440
        assert_state_variable :simple_vehicle_costs, 5000
        assert_state_variable :current_scheme_costs, 2440
        assert_state_variable :simple_total, 5000
        assert_state_variable :can_use_simple, true
      end
    end # new dirty vehicle

    context "new filthy vehicle costs 10000, 80% of time on business, expect to drive 12000 miles, (Q2, Q3, Q4, Q8, result 2)" do
      setup do
        add_response "new"
        add_response "1000" #how_much_expect_to_claim
        add_response "high" #emissions
        add_response "10000" #filthy_vehicle_price
        add_response "80" #filthy_vehicle_write_off
        add_response "12000" #simple_vehicle_costs
      end

      should "take you to result 2 - main result" do
        assert_current_node :you_can_use_result
        assert_state_variable :vehicle_filthiness, "filthy"
        assert_state_variable :filthy_vehicle_price, 800
        assert_state_variable :filthy_vehicle_write_off, 640
        assert_state_variable :simple_vehicle_costs, 5000
        assert_state_variable :current_scheme_costs, 1640
        assert_state_variable :simple_total, 5000
        assert_state_variable :can_use_simple, true
      end
    end # new filthy vehicle

    context "new green vehicle costs 260000, 100% of time on business, expect to drive 2000 miles, (Q2, Q5, Q6, Q7, Q8, result 2)" do
      setup do
        add_response "new"
        add_response "1000" #how_much_expect_to_claim
        add_response "low" #emissions
        add_response "260000" #green_vehicle_price
        add_response "100" #green_vehicle_write_off
        add_response "2000" #simple_vehicle_costs
      end

      should "take you to result 2 - main result" do
        assert_current_node :you_can_use_result
        assert_state_variable :vehicle_filthiness, "green"
        assert_state_variable :green_vehicle_price, 260000
        assert_state_variable :green_vehicle_write_off, 260000
        assert_state_variable :simple_vehicle_costs, 900
        assert_state_variable :current_scheme_costs, 261000
        assert_state_variable :simple_total, 900
        assert_state_variable :can_use_simple, false
      end
    end # new green vehicle
  end # main result, new business, car_or_van only

  context "main result, motorbike only" do
    setup do
      add_response "motorbike"
    end

    context "not buying new motorbike, not claimed CA before, expect to claim 1000 pounds, expect to drive 2000 miles, (Q3, Q4, Q5, Q10, result 2)" do
      setup do
        add_response "no"
        add_response "no"
        add_response "1000" #how_much_expect_to_claim
        add_response "10000" #dirty_vehicle_price
        add_response "80" #simple_vehicle_costs
        add_response "2000" #drive_business_miles_car_van
      end

      should "take you to result 2 - main result" do
        assert_current_node :you_can_use_result
        assert_state_variable :vehicle_costs, 1000
        assert_state_variable :simple_motorcycle_costs, 480
        assert_state_variable :current_scheme_costs, 1000
        assert_state_variable :simple_total, 480
        assert_state_variable :can_use_simple, false
      end
    end # no new vehicle
    context "new green motorcycle costs 10000, 80% of time on business, expect to drive 2000 miles, (Q2, Q5, Q6, Q7, Q9 result 2)" do
      setup do
        add_response "new"
        add_response "1000" #how_much_expect_to_claim
        add_response "low" #emissions
        add_response "10000" #green_vehicle_price
        add_response "80" #green_vehicle_write_off
        add_response "2000" #simple_motorcycle_costs
      end

      should "take you to result 2 - main result" do
        assert_current_node :you_can_use_result
        assert_state_variable :vehicle_filthiness, "green"
        assert_state_variable :green_vehicle_price, 10000
        assert_state_variable :green_vehicle_write_off, 8000
        assert_state_variable :simple_motorcycle_costs, 480
        assert_state_variable :current_scheme_costs, 9000
        assert_state_variable :simple_total, 480
        assert_state_variable :can_use_simple, false
      end
    end # new green vehicle
    context "new dirty motorcycle costs 5000, 80% of time on business, expect to drive 2000 miles, (Q2, Q5, Q6, Q7, Q9 result 2)" do
      setup do
        add_response "new"
        add_response "1000" #how_much_expect_to_claim
        add_response "medium" #dirty
        add_response '10000' #dirty_vehicle_price
        add_response "80" #dirty_vehicle_write_off
        add_response "2000" #simple_motorcycle_costs
      end

      should "take you to result 2 - main result" do
        assert_current_node :you_can_use_result
        assert_state_variable :vehicle_filthiness, "dirty"
        assert_state_variable :dirty_vehicle_price, 1800
        assert_state_variable :dirty_vehicle_write_off, 1440
        assert_state_variable :simple_motorcycle_costs, 480
        assert_state_variable :current_scheme_costs, 2440
        assert_state_variable :simple_total, 480
        assert_state_variable :can_use_simple, false
      end
    end # new dirty vehicle

    context "new filthy motorcycle costs 5000, 80% of time on business, expect to drive 2000 miles, (Q2, Q5, Q6, Q7, Q9 result 2)" do
      setup do
        add_response "new"
        add_response "1000" #how_much_expect_to_claim
        add_response "high" #filthy
        add_response '10000' #filthy_vehicle_price
        add_response "80" #filthy_vehicle_write_off
        add_response "2000" #simple_motorcycle_costs
      end

      should "take you to result 2 - main result" do
        assert_current_node :you_can_use_result
        assert_state_variable :vehicle_filthiness, "filthy"
        assert_state_variable :filthy_vehicle_price, 800
        assert_state_variable :filthy_vehicle_write_off, 640
        assert_state_variable :simple_motorcycle_costs, 480
        assert_state_variable :current_scheme_costs, 1640
        assert_state_variable :simple_total, 480
        assert_state_variable :can_use_simple, false
      end
    end # new filthy vehicle
  end # main result, existing business, motorcycle only

  context "main result, using home (Q1, Q10, Q11, result 2)" do
    setup do
      add_response "using_home_for_business"
      add_response "120" #simple_home_costs
      add_response "1000" #home_costs
    end

    should "take you to the results" do
      assert_current_node :you_can_use_result
      assert_state_variable :home_costs, 1000
      assert_state_variable :simple_home_costs, 312
      assert_state_variable :simple_total, 312
      assert_state_variable :current_scheme_costs, 1000
    end
  end # main result, existing business, using home

  context "main result, living on premises (Q1, Q10, Q11, result 2)" do
    setup do
      add_response "live_on_business_premises"
      add_response "1000" #business_premises_cost
      add_response "4" #simple_business_costs
    end

    should "take you to the results" do
      assert_current_node :you_can_use_result
      assert_state_variable :business_premises_cost, 1000
      assert_state_variable :simple_total, 0
      assert_state_variable :simple_business_costs, 7800
    end
  end # main result, existing business, living on premises

  context "main result, car, using home, new green vehicle (Q1, Q2, Q5, Q6, Q7, Q8, Q9, Q10, Q11, result 2)" do
    setup do
      add_response "car,using_home_for_business"
      add_response "new"
      add_response "1000" #how_much_expect_to_claim
      add_response "low" #emissions
      add_response "10000" #green_vehicle_price
      add_response "80" #green_write_off
      add_response "2000" #simple_vehicle_costs
      add_response "120" #simple_home_costs
      add_response "1000" #home_costs
    end

    should "take you to the results" do
      assert_current_node :you_can_use_result
      assert_state_variable :vehicle_filthiness, "green"
      assert_state_variable :green_vehicle_price, 10000
      assert_state_variable :green_vehicle_write_off, 8000
      assert_state_variable :simple_vehicle_costs, 900
      assert_state_variable :home_costs, 1000
      assert_state_variable :simple_home_costs, 312
      assert_state_variable :simple_total, 1212
      assert_state_variable :current_scheme_costs, 10000
    end
  end # main result, existing business, car_or_van, using home

  context "main result, motorbike, living on premises, no new vehicle (Q1, Q2, Q3, Q4, Q9, Q12, Q13 )" do
    setup do
      add_response "motorbike,live_on_business_premises"
      add_response "no"
      add_response "no" #capital_allowance_claimed
      add_response "1000" #vehicle_costs
      add_response "1000" #simple_motorcycle_costs
      add_response "2000" #business_premises_cost
      add_response "2" #simple_business_costs
    end
    should "take you to the results" do
      assert_current_node :you_can_use_result
      assert_state_variable :vehicle_costs, 1000
      assert_state_variable :simple_motorcycle_costs, 240
      assert_state_variable :business_premises_cost, 2000
      assert_state_variable :simple_total, 240
      assert_state_variable :simple_business_costs, 6000
      assert_state_variable :current_scheme_costs, 1000
    end
  end # main result, existing business, motorcycle, living on premises
end
