# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_Vectorial-Space-Search_session',
  :secret      => 'ca63e3570de8d4b4afd89c9ae3ba9ea604b34a304965163f99a9853a7588a36878d648724b55f37290ebb2ebdd8ee983823d4918a596dadbe9f4ebfdf1d47fe0'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
