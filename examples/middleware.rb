# This sample middleware is provided purerly as an example. 
# It is meant to be used with authlogic.
# Please use it as your own risk.
# Once I implement some type of bunyan middleware, this file will be removed.
# - @ajsharp
class BunyanMiddleware
  def initialize(app)
    @app = app
  end
  
  # there are a number of conditions where we want to bypass and not log anything
  def call(env)
    @status, @headers, @response = @app.call(env)
    if @status != 304 && @response && !@response.body.is_a?(Proc)
      Bunyan::Logger.insert(prepare_extra_fields) 
    end
    [@status, @headers, @response]
  end

  protected
    def prepare_extra_fields
      prepare_additional_response_data.merge(prepare_user_data) || {}
    end

    def prepare_additional_response_data
      unless @response.blank?
        { 'request_method' => @response.request.request_method,
          'user_agent'     => @response.request.user_agent,
          'status'         => @status,
          'request_uri'    => @response.request.request_uri,
          'request_time'   => Time.now.utc,
          'controller_action' => format_controller_action } 
      end || {}
    end

    def format_controller_action
      params = @response.request.path_parameters
      "#{params['controller']}##{params['action']}"
    end

    def prepare_user_data
      if user_exists_in_session?
        begin
          user = User.find(@response.session[user_credentials_key])
          { 'user' => { 'email'      => user.email, 
                        'first_name' => user.first_name,
                        'last_name'  => user.last_name,
                        'roles'      => user.role_names
                      } 
          }
        rescue ActiveRecord::RecordNotFound
          {}
        end
      else
        {}
      end
    end

    def user_exists_in_session?
      !!(@response != [] && @response.session && @response.session[user_credentials_key])
    end

    def user_credentials_key
      'user_credentials_id'
    end

end
