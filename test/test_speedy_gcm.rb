current_dir = File.expand_path(File.dirname(__FILE__))
require File.join(current_dir, 'helper')

require 'json'
require "net/http"
require "net/https"

class TestSpeedyGCM < Test::Unit::TestCase

  # If you receive an "Unavailable" error code when you try to send a GCM:
  # Generate a Browser API Key from the Google APIs Console, and use it instead of the server key in the "Authorization" header. Once you do that, this error will go away.
  # This is caused by a serious mistake in the GCM Documentation that states you should use a Server Key in the Authorization header (as written here:  http://developer.android.com/guide/google/gcm/gs.html)

  # use a "browser_api_key" - see note above!
  GCM_API_KEY = "TODO - Fill in with your GCM API Key"
  TEST_PHONE_GCM_REGISTRATION_ID = "TODO - Fill in with some GCM Registration ID"

  should "not raise an error if the API key is valid" do
    assert_nothing_raised do
      SpeedyGCM::API.set_account(GCM_API_KEY)
    end
  end

  should "raise an error if the api key is not provided" do
    assert_raise(ArgumentError) do
      SpeedyGCM::API.set_account()
    end
  end

  should "raise an error if the registration_ids are not provided" do
    SpeedyGCM::API.set_account(GCM_API_KEY)

    assert_raise(ArgumentError) do
      message_options = {}
      # message_options.merge!({ :registration_ids => [1,2] })
      message_options.merge!({ :collapse_key => "foobar" })
      message_options.merge!({ :data => { :score => "3x1" } })
      message_options.merge!({ :delay_while_idle => true })
      message_options.merge!({ :time_to_live => 1 })

      response = SpeedyGCM::API.send_notification(message_options)
    end
  end

  should "raise an error if the time_to_live is provided but collapse_key is not" do
    SpeedyGCM::API.set_account(GCM_API_KEY)

    assert_raise(ArgumentError) do
      message_options = {}
      message_options.merge!({ :registration_ids => [1,2] })
      # message_options.merge!({ :collapse_key => "foobar" })
      message_options.merge!({ :data => { :score => "3x1" } })
      message_options.merge!({ :delay_while_idle => true })
      message_options.merge!({ :time_to_live => 1 })

      response = SpeedyGCM::API.send_notification(message_options)
    end
  end

  should "raise an error if the time_to_live is provided but it is not an integer" do
    SpeedyGCM::API.set_account(GCM_API_KEY)

    assert_raise(ArgumentError) do
      message_options = {}
      message_options.merge!({ :registration_ids => [1,2] })
      message_options.merge!({ :collapse_key => "foobar" })
      message_options.merge!({ :data => { :score => "3x1" } })
      message_options.merge!({ :time_to_live => "a" })

      response = SpeedyGCM::API.send_notification(message_options)
    end

    assert_nothing_raised do
      message_options = {}
      message_options.merge!({ :registration_ids => [1,2] })
      message_options.merge!({ :collapse_key => "foobar" })
      message_options.merge!({ :data => { :score => "3x1" } })
      message_options.merge!({ :time_to_live => 1 })

      response = SpeedyGCM::API.send_notification(message_options)
    end
  end

  should "check that delay_while_idle is a boolean if provided" do
    SpeedyGCM::API.set_account(GCM_API_KEY)

    assert_raise(ArgumentError) do
      message_options = {}
      message_options.merge!({ :registration_ids => [1,2] })
      message_options.merge!({ :collapse_key => "foobar" })
      message_options.merge!({ :data => { :score => "3x1" } })
      message_options.merge!({ :delay_while_idle => nil })
      message_options.merge!({ :time_to_live => 1 })

      response = SpeedyGCM::API.send_notification(message_options)
    end

    assert_nothing_raised do
      message_options = {}
      message_options.merge!({ :registration_ids => [1,2] })
      message_options.merge!({ :collapse_key => "foobar" })
      message_options.merge!({ :data => { :score => "3x1" } })
      message_options.merge!({ :delay_while_idle => true })
      message_options.merge!({ :time_to_live => 1 })

      response = SpeedyGCM::API.send_notification(message_options)
    end

    assert_nothing_raised do
      message_options = {}
      message_options.merge!({ :registration_ids => [1,2] })
      message_options.merge!({ :collapse_key => "foobar" })
      message_options.merge!({ :data => { :score => "3x1" } })
      message_options.merge!({ :delay_while_idle => false })
      message_options.merge!({ :time_to_live => 1 })

      response = SpeedyGCM::API.send_notification(message_options)
    end
  end

  should "raise error if registration_ids contain no registration IDs" do
    SpeedyGCM::API.set_account(GCM_API_KEY)

    assert_raise(ArgumentError) do
      message_options = {}
      message_options.merge!({ :registration_ids => [] })
      message_options.merge!({ :collapse_key => "foobar" })
      message_options.merge!({ :data => { :score => "3x1" } })
      message_options.merge!({ :time_to_live => 1 })

      response = SpeedyGCM::API.send_notification(message_options)
    end
  end

  should "raise error if registration_ids contains more than 1000 registration IDs" do
    assert_raise(ArgumentError) do
      SpeedyGCM::API.set_account(GCM_API_KEY)

      reg_ids = *(1..1001)

      message_options = {}
      message_options.merge!({ :registration_ids => reg_ids })
      message_options.merge!({ :collapse_key => "foobar" })
      message_options.merge!({ :data => { :score => "3x1" } })
      message_options.merge!({ :time_to_live => 1 })

      response = SpeedyGCM::API.send_notification(message_options)
    end
  end

  should "not raise an error and send a message with a success response" do
    assert_nothing_raised do
      SpeedyGCM::API.set_account(GCM_API_KEY)

      message_options = {}
      message_options.merge!({ :registration_ids => [TEST_PHONE_GCM_REGISTRATION_ID] })
      message_options.merge!({ :collapse_key => Time.now.to_s })
      message_options.merge!({ :data => { :vmr_id => "3" } })

      response = SpeedyGCM::API.send_notification(message_options)

      assert response[:code].eql? 200
    end
  end

  should "not raise an error and send a message with a success response if using strings instead of symbols for keys" do
    assert_nothing_raised do
      SpeedyGCM::API.set_account(GCM_API_KEY)

      message_options = {}
      message_options.merge!({ "registration_ids" => [TEST_PHONE_GCM_REGISTRATION_ID] })
      message_options.merge!({ "collapse_key" => Time.now.to_s })
      message_options.merge!({ "data" => { "vmr_id" => "3" } })

      response = SpeedyGCM::API.send_notification(message_options)

      assert response[:code].eql? 200
    end
  end

end