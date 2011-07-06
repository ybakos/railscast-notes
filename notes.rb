# Railscast 1
# for global methods that are expensive (eg, AR find)
# and can be called many times during 1 request, use ||=
def current_user
  @user ||= User.find(session[:user_id])
end

# Railscast 2
# Is there a way to do find_by_:ar_relationship_name? eg...
class User
  belongs_to :group
end
g = Group.find(1)
u = User.find_by_group(g)
# Also...
Task.find_all_by_complete_and_category_id(false, 1)

# Railscast 3
# You can use finders on association names...
@project = Project.find(params[:id])
@tasks = Task.find(:all, :conditions => ['project_id = ?', 'complete = ?'], @project.id, false)
# the above becomes
@tasks = @project.tasks.find(:conditions => ['complete = ?'], false)
# or even
@tasks = @project.tasks.find_all_by_complete(false)

# Railscast 4
# You can use class methods through associations...
class Task
  belongs_to :project
  defself.incompletes
    find_all_by_complete(false, :order => 'created_at DESC') #note no need for Task. or self. prefix, already in scope
  end
end
@incomplete_tasks = @project.tasks.incompletes

# Railscast 5
# Use with_scope to pass options to finders w/o having to merge a hash of options together.
# in controller:
# Some conflict over this things use. In a nutshell, only use it with dynamic finders like so...
@twenty_incompletes = Task.incompletes :limit => 20
# in Task class:
defself.incompletes(options = {})
  with_scope :find => options do
    find_all_by_complete(false, :order => 'created_at DESC')
  end
end

# Railscast 6
# Awesome, use to_proc in lieu of a block when you're just calling the same method
# on every object in the collection. eg...
projects.collect {|p| p.name}
['Name1','Name2']
projects.collect(&:name)
['Name1','Name2']
# and you can chain to_proc!
projects.collect(&:name).collect(&:downcase)
['name1','name2']
# can be used on any method that takes a block!
projects.all?(&:valid?)
projects.any?(&:valid?)
projects.each(&:save!)

# Railscast 7
# You can dynamically choose layouts by passing a symbol to the layout method
# And you must define that :symbol as a function, which can perform logic.
layout :user_layout
def user_layout
  if user.logged_id
    'admin'
  else
    'public'
  end
end
# and you can choose a layout per action, eg, in the action method...
render :layout => 'admin'
# or
render :layout => false

# Railscast 8
# Use content_for to modify layouts from the perspective of a view.
# In the view...
# <% content_for :head do %>
#  <%= stylehseet_link_tag 'projects' %>
# <% end %>

# And in the layout...
# <%= yield :head %>

# Railscast 9
filter_paramter_logging :password

# Railscast 10
# Refactoring.

# Rails cast 11
# Testing while refactoring. Check out autotest, which runs tests continually
# in the background.
# Refactoring string concatentation
class User
  def full_name
    name = first_name + " "
    name += "#{middle_initial}. "unless middle_initial.nil?
    name += last_name
    name
  end
end
# method full_name becomes...
[first_name, middle_initial_with_period, last_name].compact.join(' ')
def middle_initial_with_period
  "#{middle_initial.}"unless middle_initial.blank?
end
# blank? is a rails extension for nil or empty string.
# compact removes nil elements from array.
# Reader adds...
[f, m, l].reject{|i| i.empty?}.compact.join(" ")
# to prevent blanks...

# Railscast 12
# Refactoring tests
# Combine multiple tests of some similar aspect (eg varying value cases)
# into one test, that calls another test method to create the comparison
# value.
# asserts can take a second parameter, 'message'
def test_full_name
  assert_equal 'John Doe', full_name('John',nil,'Doe'), 'nil middle initial'
  assert_equal 'John H. Doe', full_name('John', 'H', 'Doe'), 'H middle initial'
  assert_equal 'John Doe', full_name('John', '', 'Doe'), 'blank middle initial'
end
def full_name(first, middle, last)
  User.new(:first_name=>first,:middle_initial=>middle,:last_name=>last).full_name
end
# NOTE that many people say one assert per test is better.

# Railscast 13
# Don't store models in session

# Railscast 14
# Model calculations...
Task.sum(:priority)
Task.sum(:priority, :conditions => 'complete=0')
# maximum, minimum, average...
# and they work across associations...
p = Project.find(:first)
p.tasks.sum(:priority)
# SELECT count(priority) from tasks WHERE project_id = 1

# Railscast 15
# AR finders can accept a HASH for :conditions
Task.count(:all, :conditions => ['complete=? and priority in (?)', false, 1..3])
# becomes
Task.count(:all, :conditions => {:complete => false, :priority => 1..3})
# the hash will intelligently create the correct sql for a value type (eg, IN, BETWEEN, =, etc)
# dynamic finders also accept different value types, eg
Tasks.find_all_by_complete(1..3).count

# Railscast 16
# Adding attributes to models.
def full_name
  [first_name,last_name].join(' ')
end
def full_name=(name)
  split_name = name.split(' ', 2)
  self.first_name = split_name.first
  self.last_name = split_name.last
end

# Railscast 17
# Checkboxes for habtm (eg, categories)
# for category in @categories
# <%= check_box_tag 'product[category_ids][]', category.id, @product.categories.include?(category) %>
# <%= category.name %>
# end
# in order to allow for 'no checkboxes checked' to mean 'no categories'
# add the following to the action:
params[:product][:category_ids] ||= []
# habtm provides the cateory_ids method, such that
product.category_ids = [1,2]
# immediately updates the join table.

# Railscast 18
# Refactoring flash display.
# <% flash.each do |key,msg| %>
#   <%= content_tag :div, msg, :id => key %>
# <% end %>

# Railscast 19
# Inline Admin access to your app
# Recommends adding linked actions for edit, delete, new etc.

# Railscast 20
# Restricing access for admin
# You can declare any controller action as a helper with
helper_method :method_name
# To prevent direct url access, use a before_filter

# Railscast 21
# Simple authentication
# Contains example of routing, eg:
map.home '', :controller => 'episodes', :action => 'index'
map.login 'login', :controller => 'sessions', :action => 'new'
map.logout 'logout', :controller => 'sessions', :action => 'destroy'

# Railscast 22
# Eager loading
Model.find(:all, :include => :project)
Model.find(:all, :include => [:project, :comment])
Model.find(:all, :include => [:project, {:comment => :user}])

# Railscast 23
# Counter caches
# Optimizes
loop
  project.tasks.size
end
# In migration...
# Add tasks_count integer default 0
Project.reset_column_information
Project.find(:all).each do |p|
  p.update_attribute :tasks_count, p.tasks.length #length does not use counter-cache
end
# In the tasks model
belongs_to :project, :counter_cache => true

# Railscast 24
# Stack trace
# Demonstrates use of textmate_footnotes plugin
# and installing via RoR textmate bundle

# Railscast 25
# SQL Injection
# use the :conditions => [] approach to leverage rails auto-escaping

# Railscast 26
# Be very wary of mass assignment, eg User.new(params[:user])
# as sensitive fields can be hacked.
# In a model, use
:attr_protected => :admin
:attr_accessible => :name, :email, :password

# Railscast 27
# XSS
# use h() or sanitize() before rendering output
# use CGI::escapeHTML() to sanitize user input in the ctrlr, eg, before storing in the db.
# not preferred, since data might be displayed elsewhere, eg not as html.

# Railscast 28
# Using in_groups_of
# array shortcut:
a = (1..12).to_a
a.in_groups_of(4) # [[1,2,3,4],[5,6,7,8],[9,10,11,12]]
a.in_groups_of(5) # [[1,2,3,4,5],[6,7,8,9,10],[11,12,nil,nil,nil]]
a.in_groups_of(5, false) # [[1,2,3,4,5],[6,7,8,9,10],[11,12]]
a.in_groups_of(5, 0) # [[1,2,3,4,5],[6,7,8,9,10],[11,12,0,0,0]]
# explore Array.transpose to flip this structure into columns

# Railscast 29
# Using group_by with arrays
[1,2,3,4,5,6,7,8].group_by {|n| n/2} # return hash {0=>[1],1=>[2,3],2=>[4,5],3=>[6,7],4=>[8]}

# Railscast 30
# Page titles
# Believes title logic belongs in helpers/views, not actions.
# Makes point of being able to re-use view w/o needing to re-declare title in action.
# Use yield :title and a helper method that executes content_for :title

# Railscast 31
# Achieve task.due_date.to_s(:my_meaningful_name)
# by Time::DATE_FORMATS[:due_time] = "due at %B %d ..." in environment.rb
# or ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS[:due_on] = '%m-%d-%y' for Rails2

# Railscast 32
# Virtual attributes in model (Time as text field)
Time.parse(some_string)
# Check out chronic gem for strtotime-style functionality.
def due_at_string # where due_at is an AR model attribute
  due_date.to_s(:db)
end
def due_at_string=(due_str)
  self.due_date = Time.parse(due_str) # would produce an error in cases where due_str is invalid, so...
  rescue ArgumentInvalidError
    @due_at_is_invalid = true#checked by validate
end
def validate
  errors.add(:due_date, 'is invalid') if @due_at_is_invalid
end

# Railscast 33
# Making plugins
# Given the above, say you have a lo of date fields you want to handle similarly.
# Rather than define each get/set by hand, you'd prefer to declare:
stringify_time :due_at, :some_date, :another_date, :etc
# So, generate a plugin...
script/generate plugin stringify_time
# when loading a plugin, rails runs the plugin's init.rb, so in init.rb declare
require'stringify_time'
# which will load lib/stringify_time.rb...
defmodule StringifyTime
  def stringify_time(*names)
    names.each do |name|                                      #
      define_method "#{name}_string"do                      # module_eval <<-EOV
        read_attribute(name).to_s(:db)# send(name.to_sym)     # def #{name}_string
      end                                                    #   #{name}.to_s(:db)
      define_method "#{name}_string="do |time_str|           # end
        begin                                                # EOV
          write_attribute(name, Time.parse(time_str)) # send("#{name=}".to_sym)
        rescue
          instance_variable_set("@#{name}_invalid", true)
        end
      end
    end
  end
end
# Ok, but to make the method available to AR, you must declare the extension in init.rb
#init.rb...
require'stringify_time'
class ActiveRecord::Base
  extend StringifyTime # extends adds module as class methods
end
# and the old model validate method (see RC 32) should move into the plugin too:
define_method "#{name}_invalid?"do
  instance_variable_get("@#{name}_invalid")
end

# Railscast 34
# Named routes
map.home '', :controller => 'projects', :action => 'index'
# gives you home_path, home_url
map.task_archive 'tasks/:year/:month', :ctrlr => 'tasks', :action => 'archive'
# gives you task_archive_url(yr, month) or task_archive_url({:year, :month})
map.resource :projects
# gives you named routes, eg project_path(p), edit_project_path(p), new_project_path, projects_path

# Railscast 35
# Custom REST actions
# REST: index, show, new, create, edit, update, destroy
# in your controller...
def completed
  @tasks = Task.find(:conditions => completed)
end
# and in routes rb...
map.resources :tasks, :collection => {:completed => :get}
# gives you /tasks/completed and completed_tasks_path
#                                action    ctrlr
# Say you want to have another action...
def complete
  @task = Task.find(params[:id])
  @task.update_attr :completed_at, Time.now
  flash[:notice] = 'Completed the task.'
  redirect_to completed_tasks_path
end
# you would need to...
map.resources :tasks, :member => {:complete => :put}
# Which gives you completed_task_path(task), :method => :put
# When creating custom actions, consider additional model/ctrlrs, like a CompletionController


# Railscast 36
# SVN & RAils
svn propset svn:ignore filename dir/  # specifices filename in dir
svn propset svn:ignore "*" dir/       # all files in dir
# Textmate: ctrl-shift-A provides svn ui
script/gen -c # add to working copy
script/plugin install -x #to install as external

# Railscast 37
# Simple search form (model-less ctrlrs)
form_tag projects_path, :method => :get do# get, because post would call new
  text_field_tag :seach, params[:search] # for redisplay
  submit_tag 'Search', :name => nil  # to remove button from parameters
end
# in your ctrlr...
def index
  @projects = Project.search(params[:search])
end
# in your model...
defself.search(q)
  if q then run__custom_find elsereturnend
end

# Railscast 38
# Multi-button forms
<!-- projects/new.rhtml -->
<% if params[:preview_button] %>
  <%= textilize @project.description %>
<% end %>
...
<%= submit_tag 'Create' %>
<%= submit_tag 'Preview', :name => 'preview_button' %>
# projects_controller.rb
def create
  @project = Project.new(params[:project])
  if params[:preview_button] || !@project.save
    render :action => 'new'
  else
    flash[:notice] = "Successfully created project."
    redirect_to project_path(@project)
  end
end

# Railscast 39
# Custom error fields                           #form_field   #the ruby field object
ActionView::Base.field_error_proc = Proc.new do |html_tag, instance_tag|
  "<span class='my_custom_tag_wrapper'> #{html_tag}</span>"
end
# or to modify the tag itself...
ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  error_style = "background-color: #ffff80"
  if html_tag =~ /<(input|textarea|select)[^>]+style=/
    style_attribute = html_tag =~ /style=['"]/
    html_tag.insert(style_attribute + 7, "#{error_style}; ")
  elsif html_tag =~ /<(input|textarea|select)/
    first_whitespace = html_tag =~ /\s/
    html_tag[first_whitespace] = " style='#{error_style}' "
  end
  html_tag
end

# Railscast 40
# Using blocks in a view
# application_helper.rb
def side_section(&block)
  @side_sections ||= []
  @side_sections << capture(&block)
end

def admin_area(&block)
  concat('<div class="admin"]] > ', block.binding)
  block.call
  concat("</div>", block.binding)
end
# or...
def admin_area(&block)
  if admin?
    concat content_tag(:div, capture(&block), :class => 'admin'), block.binding
  end                        # think block.to_s
end
# and in the view...
- admin_area do
  # stuff
- sidebar do
  # sidebar

# Railscast 41
# Conditional validation, where ctrlr can control validation rules
class Model < ActiveRecord::Base
  validates_presence_of :password, :if => :should_validate_password?
  validates_presence_of :country
  validates_presence_of :state, :if => :in_us?
  attr_accessor :updating_password

  def in_us?
    country == 'US'
  end

  def should_validate_password?
    updating_password || new_record?
  end
end
# in controller
@model.updating_password = true
@model.save  # or @user.save(false) to bypass validations

# Railscast 42
# with_options
# If you're passing identical options to multiple methods...
with_options :if => shoud_validate_password? do |model|
  model.validate_presence_of :name
  model.validate_presence_of :password
end
# this is handy with routes:
map.login 'login', :controller => 'sessions', :action => 'new'
map.login 'logout', :controller => 'sessions', :action => 'destroy'
# becomes
map.with_options :controller => 'sessions', do |user| # convention is to use name of
  user.login 'login', :action => 'new'                # controller but you're working
  user.logout 'logout', :action => 'destroy'          # with the 'map' object
end

# Railscast 43
# Ajax w/ rjs. (use rjs, not older rails ways)
form_remote_for ...
# in your controller...
def create
  @model = Model.create!(params[:review])
    flash[:notice] = "Thank you for reviewing this product"
    respond_to do |format|
      format.html { redirect_to some_path(@model.id) }
      format.js
    end
end
# in create.rjs...
page.insert_html :bottom, :div_name, :partial => 'some_partial', :object => @model
page.replace_html :div_name, 'your content string'
page[:review_form].reset # calls reset on element 'review_form' via js
page.replace_html :notice, flash[:notice]
flash.discard # to prevent existence of flash through the next request

# Railscast 44
# Debugging rjs
# See firebug response headers, etc (ctrl-shift-l)
# When you see rjs alert "TypeError - Null value", often means no element id was found

# Railscast 45
# RJS Tips
# referring to elements in two ways...
page.toggle :element_id
# alternatively
page[:element_id].toggle
# To generate js if conditions (since we are generating js)
page << "if ($('element_id).value == '') {"
page.alert
page << "}"
# page.select returns an array, allowing you to iterate over each item...
page.select('#element_id strong').each do |e|
  e.visual_effect :highlight # (wasteful visual effect via ajax)
end
# and don't forget you can use rjs in any view...
link_to_function 'clickme'do |page|
  # rjs here...
end

# Railscast 46
# Catch-all routing ** handy for redirecting old urls!
map.connect "*path", :controller => 'redirect', :action => 'index'
# puts everything in actual path into params array called 'path'
# redirect_controller.rb
def index
  product = Product.find(:first, :conditions => ["name LIKE ?", "#{params[:path].first}%"])
  redirect_to product_path(product)
end
# ** .inspect() on a hash renders it to a string
# ** request.request_uri

# Railscast 47
# has_many :through
# think -tion, -ship, -ment when naming
# Reasons: need to store extra info in join? Need to treat join like its own model?

# Railscast 48
# Console tricks
console --sandbox # rolls back all db changes
y() # yamlize
pp() # pretty-prints. require 'pp' first
app # ActionController session
app.get '/projects'
app.flash
app.assigns[:projects]
app.cookies
# ** .methods()  returns a list of object methods
app.methods.grep(/_path$/).sort
helper.text_field_tag :foo
_ # variable name, always set as output of previous command
# use .irbrc containing ruby commands to run before console loads
# append a dummy command to prevent the evaluation from printing to stdout, eg
actors = Actor.find_all ; 1
# see wirble gem for syntax highlighting and autocomplete

# Railscast 49
# Reading api docs... see railsapi.org, railsmanual.org (history), railsbrain.com

# Railscast 50
# Contributing to Rails
# 1) Search trac/github to pre-empt duplication
# 2) Checkout rails edge, place in vendor/rails of an application
# 3) Run test suite
# --- see vendor/rails/running_unit_tests readme
# --- create dbs: ar_unittest, unittest2
# --- create db user 'rails'
# --- cd activerecord; rake test_mysql
# --- cd actionpack; rake test
# 4) Update local working copy / repo
# 5) Make change. Run tests again.
# 6) If changing documentation, run rake doc:rails from app root
# 7) Run a svn/git status, to make sure you didn't change something accidentally
# 8) svn diff vendor/rails > ~/my_path.diff
# 9) Create ticket.
# --- Summary field: start with [PATCH]
# --- Keywords field: important! eg, use 'docs' for doco changes

# Railscast 51
# will_paginate
Model.paginate(:page => 1, :per_page => 5) # Returns a smart WillPaginate::Collection
def Model
  defself.search(query, page)
    paginate(:page => page, :per_page => 5, :conditions => [...])
  end
end

def ctrl_method
  @models = Model.search(params[:query], params[:page])
end

# Railscast 52
# Selecting all checkboxes eg, 'mark all complete'
# declare route...
map.resources :tasks, :collection => {:complete => :put}
# controller...
def complete
    Task.update_all(["completed_at=?", Time.now], :id => params[:task_ids])
  end
  redirect_to tasks_path
end
# form...
- form_tag tasks_path, :method => :put do
  - @tasks.each do |task|
    %p
      = check_box_tag 'tasks_id[]', task.id
      = task.name
  = submit_tag 'Mark as Complete'

# Railscast 53
# Exception handling
# in application.rb
protected
def local_request? #override
  false            # could do more with this, eg, control error reporting
end                # per user type, etc.
# in 2.x AR Not Found returns 404
# To control what happens when ex is raised...
def rescue_action_in_public(exception)
  case exception
  when ActiveRecord::RecordNotFound
    render => :file => "#{RAILS_ROOT}/public/404.html", :status => 404
  end
end

# Railscast 54
# Ruby-debug

# Railscast 55
# View refactoring
array.each_with_index do |thing, i| # where i is counter, starts at 0
# smells: assignments (duh) and operations.
# push to helpers, model methods, and partials (duh)

# Railscast 56
# The Logger
# debug info warn error fatal
config.log_level # default = info
config.logger = MyLogger.new() # or log4r, etc
class Logger
  def format_message(level, time, progname, msg)
    "#{time.to_s(:db)} #{level} -- #{msg}\n"
  end
end
# For logging in console,  ~/.irbrc
if ENV.include?('RAILS_ENV') && !Object.const_defined?('RAILS_DEFAULT_LOGGER')
  require'logger'
  RAILS_DEFAULT_LOGGER = Logger.new(STDOUT)
end

# Railscast 57
# Build model from text field argument
# eg, Category [select] or create new category: [         ]
# belongs_to :model adds builder functions like create_model(attrs)
# In view, add field named after virtual attr accessor, and in model:
# models/product.rb
belongs_to :category
attr_accessor :new_category_name
before_save :create_category_from_name

def create_category_from_name
  create_category(:name => new_category_name) unless new_category_name.blank?
end



# Railscast 58
# Creating generators
# Rails looks for generators in plugins, gems, and in ~/.rails/generators/[generator_name]
# Generators need certain files: USAGE, [generator_name]_generator.rb
#             And certain dirs: /templates
class AppLayoutGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.file 'layout.rhtml', 'apps/views/layouts/application.rhtml'
      m.file 'main.css', 'public/stylesheets/application.css'
    end
  end
end
# or to do a script/generate app_layout myname
class AppLayoutGenerator < Rails::Generator::NamedBase
  def manifest
    record do |m|
      m.file 'layout.rhtml', "apps/views/layouts/#{file_name}.rhtml"
      m.file 'main.css', "public/stylesheets/#{file_name}.css"
    end
  end
end
# and to modify the template...
m.template 'layout.rhtml', "apps/views/layouts/#{file_name}.rhtml"
# and in the template, escape the rhtml tags; template has access to all vars in generator script
<%%= stylesheet_link_tag '<%= file_name %>' %>
# Try copying an existing generator and looking at the source.

# Railscast 59
# Optimistic locking
# In cases where you want to prevent edits from overriding one another.
# eg, user 1 opens edit, user 2 opens edit, user 1 saves changes, user 2 saves changes, user 1 changes are lost.
# Rails offers a lock_version field for tables, that increment every time there's an update.
# We pass that value through the form, allowing rails to check if the proposed edit is out of date.
add_column :models, :lock_version, :integer, :default => 0, :null => false
f.hidden_field :lock_version
rescue ActiveRecord::StaleObjectError
  @model.reload
  render :action => 'something'

# Railscast 60
# Testing w/o fixtures
# Discourages fixtures due to test dependencies across models and associations
# Recommends building models as you need them in the test.
# Mocha gem to create mock stubs for models
cart.line_items.build.stubs(:weight).returns(3)

# Railscast 61
# Creating emails

# Railscast 62
# Hacking ActiveRecord, eg disabling validation.
# Say you want to do some ActiveRecord stuff but without all the AR behavior...
disable_validation do
  # some stuff
end
# you would have to define
def disable_validation
  ActiveRecord::Base.disable_validation!
  yield
  ActiveRecord::Base.enable_validation!
end
# and define the disable_validation methods in a module that you add to AR::Base
class ActiveRecord::Base
  include validation_disabler
end
module ValidationDisabler
end
# but module methods become instance methods, not class methods, so the convention
# is to define a second module in the module.
module ValidationDisabler
  module ClassMethods
    def disable_validation!
      @@disable_validation = true
    end
    def enable_validation!
      @@disable_validation = false
    end
    def validation_disabled?
      @@disable_validation
    end
end
# But... the inner module isn't doing much by itself... you have to...
module ValidationDisabler
  defself.included(base)
  end
#...
end
# When the include is declared as below, it calls the included method w/ itself as the parameter
class ActiveRecord::Base
  include validation_disabler
end
# So then you...
defself.included(base)
  base.class_eval do
    extend ClassMethods
  end
end
# But... AR is still going to call method valid? So the first thought is to override it...
module ValidationDisabler
  def valid?
  end
end
# but you should use alias_method_chain
alias_method_chain :valid?, :disable_check
# gives you...
def valid_with_disable_check?
  ifself.class.validation_disabled?
    true
  else
    #and gives you...
    valid_without_disable_check?
  end
end
# In the end, we've got...
# test_helper.rb
class Test::Unit::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false

  def disable_validation
    ActiveRecord::Base.disable_validation!
    yield
    ActiveRecord::Base.enable_validation!
  end
end
module ValidationDisabler
  defself.included(base)
    base.class_eval do
      extend ClassMethods
      alias_method_chain :valid?, :disable_check
    end
  end
  def valid_with_disable_check?
    ifself.class.validation_disabled?
      true
    else
      valid_without_disable_check?
    end
  end
  module ClassMethods
    def disable_validation!
      @@disable_validation = true
    end

    def enable_validation!
      @@disable_validation = false
    end

    def validation_disabled?
      @@disable_validation ||= false
    end
  end
end
class ActiveRecord::Base
  include ValidationDisabler #calls ValidationDisabler.included(ActiveRecord::Base)
end

# Railscast 63
# Permalinks using to_param
# a handy trick...
def to_param
  "#{id}-#{permalink}"
end
# will work with existing finders, eg find(3) because rails calls params[:id].to_i and ruby drops characters after the last digit

# Railscast 64
# Custom helper modules
# Sharing helper methods across ctrlrs usually means throwing them into aplication_helper.
# But this ends as a long list of misc methods. Instead, you could group similar helper methods
# into respective ctrlr-agnostic helpers, based on purpose.
module MyPurposeHelper
  # helper methods
end
# So instead of having a bunch of ctrlr-specific helpers, try organizing helpers by purpose
# and declaring helper :all in application ctrlr.

# Railscast 65
# Spam & Akismet
# Add some fields like ip, referrer, user_agent, etc. to your model table
# Associate a request with the model.
# Use a before_create event handler on the model like :check_for_spam that uses the
# Akismetor plugin that does the heavy lifting
# Akismetor service call needs akismet attributes, so you should define these in a method
# For clean passing as an Akismetor parameter
# Modify your model actions/views to handle display and editing of all posts, eg marking them as spam/not-spam.
# Marking them spam/not-spam needs to rely on model methods to send to Akismet
# eg, mark_as_ham!, mark_as_spam! and routing
# OR try defensio.com


# Railscast 66
# Custom rake tasks
rake -T # list all tasks
# put myrakefile.rake in lib/tasks
task :greet do
  #stuff
end
# can create dependencies like so...
task :say => :greet do
end
# or multiple...
task :say => [:one, :two] # btw, no block necessary
# to access rails env, declare dependency on rails task :environment
task :some_task => :environment
  Model.find(:first)
end
# use namespace method for namespacing
namespace :my do
  task :hello do
  end
end
# use desc to describe a task
desc 'Some shit'

# Railscast 67
# Restful authentication
# install plugin restful_authentication
# run the generator...
script/generate authenticated user session
# generates a migration for user too.
# in application.rb...
include AuthenticatedSystem

# Railscast 68
# OpenID Authentication
gem install ruby-openid
install open_id_authentication
# run the rake task to gen a migration
# add an string:identity_url to your user table
# add route
map.open_id_complete 'session', :controller => 'session', :action => 'create', :requirements => {:method => :get}
# add identity_url to login form
# handle shit in controller

# Railscast 69
# Markaby in helper
# When you need to generate a lot of markup in a helper, us a patial or content_tag helper
content_tag
# or try markaby, install markaby plugin
# in helper
def simple_error_messages_for(object_name)
  object = instance_variable_get("@#{object_name}")
  returnif object.errors.empty?
  markaby do
    div.error_messages! do# div id is error_messages
      h2 "#{pluralize(object.errors.count, 'error')} occurred"
      p "There were problems with the following fields:"
      ul do
        object.errors.each_full do |msg|
          li msg
        end
      end
    end
  end
end
# This is just a convenience method
def markaby(&block)
  Markaby::Builder.new({}, self, &block)
end

# Railscast 70
# Custom Routes
# By default, routes need to match each variable specified, eg, year, month, day
# Pass them as nil by default to make them optional
# For route conflicts, you can declare a :requirements hash to set a condition on the route

# Railscast 71
# Controller testing w/ Rspec
# Try using mocha for stubs/mocks
# Stub rather than mock, if possible, to avoid test dependencies
# Best practice is to do one assert per test... but can be a performance drain when testing ctrlrs
describe MenuItemsController, "creating a new menu item"do
  integrate_views
  fixtures :menu_items
  it "should redirect to index with a notice on successful save"do
    MenuItem.any_instance.stubs(:valid?).returns(true)
    post 'create'
    assigns[:menu_item].should_not be_new_record
    flash[:notice].should_not be_nil
    response.should redirect_to(menu_items_path)
  end
  it "should re-render new template on failed save"do
    MenuItem.any_instance.stubs(:valid?).returns(false)
    post 'create'
    assigns[:menu_item].should be_new_record
    flash[:notice].should be_nil
    response.should render_template('new')
  end
  it "should pass params to menu item"do
    post 'create', :menu_item => { :name => 'Plain' }
    assigns[:menu_item].name.should == 'Plain'
  end
end

# Railscast 72
# Custom environments
# *** Ctrl-Shift-D to duplicate selected text in tm!


# Railscast 73
# Complex forms
# NOTE: seems the goal here is to streamline the controller, so you can do one mass assignment.
# use fields_for to 'change the context' of the form. Think 'embedding a new form w/o form tags'
# Given Project has_many :tasks
#new.html.haml
- form_for :project, :url => projects_path do |f|
  %p
    Name:
    = f.text_field :name
  - for task in @project.tasks
    fields_for "project[task_attributes][]", task do |task_form|
      %p
        Task:
        = task_form.text_field :name
  %p= submit_tag "Create Project"
# projects_controller.rb
def new
  @project = Project.new
  3.times { @project.tasks.build } # use _build_ to create three empty tasks assoc w/ @project
end
def create
  @project = Project.new(params[:project])
  if @project.save
    flash[:notice] = "Successfully created project."
    redirect_to projects_path
  else
    render :action => 'new'
  end
end
# models/project.rb
def task_attributes=(task_attributes)
  task_attributes.each do |attributes|
    tasks.build(attributes)
  end
end

# Railscast 74
# Rendering additional form fields dynamically
# *** Ctrl-Shift H create partial
# Put the fields_for in a partial
# Add a link_to_function with options to render the partial, passing it a Model.new
# In the partial, implement a 'remove' link_to_function using inline js,  link_to_function "remove", "$(this).up('.task').remove()

# Railscast 75
# Complex forms, editing project and multiple tasks in one form
# Rails automatically fills form 'array-style' attribute names with the id., eg project[task_attributes][] => project[task_attributes][24]
f.text_field :name, :index => nil#prevents rails from populating field name array w/ index (eg project[task_attributes][#])
# I'm not sure I like the overall design approach in this episode.
# I also don't agree about the reliance on ordered task attributes, eg, the way he uses id.

# Railscast 76
# scope_out plugin, for improving conditional finds. Kinda like named scope.
scope_out :incomplete, :conditions => [] # creates Model.find_incomplete()
# Model.find_incomplete(:all, :order => 'name')
Model.with_incomplete do  #you can pass a block, and the scoped_out shit will be used for finders in the block.
  @models = Model.find(:all)
end
Model.find_all_incomplate_by_priority(3) # enhances Rails dynamic named finders
# association finders can use caching...
@tasks = @project.tasks.find_incomplete(:all) # by passing :extend => Task::AssociationMethods to the Project has_many :tasks declaration.

# Railscast 77
# Destroy w/o JS
# Suggests some alternatives for js workarounds, eg:
# Use button_to, but you lose confirmation prompt
# Create custom action that presents a confirmation page
# Create a custom js function and helper that does the usual, or falls back to the confirmation action when no js.

# Railscast 78
# PDF Generation with PDF::Writer
# install gem, require 'pdf/writer' in environment.rb
format.pdf do |p|
  pdf=PDF::Writer.new
  pdf.text = 'hello'
  send_data pdf.render, :filename => 'products.pdf', :type => 'application/pdf', :disposition=>'inline'
end
#BUT for respond_to to work, you need to tell rails of the mime type
Mime::Type.register 'application/pdf', :pdf
# but, rendering shit in the controller is dumb, so...
# define a new 'drawer' class to encapsulate the rendering statements, so you can
send_data ProductDrawer.draw(@products)
# Named routes
link_to formatted_products_path # generates url w/ format extension, eg products.pdf

# Railscast 79
# Generate named routes
# Illustrated dynamic nature of ruby: ability to define new method on object instance (and not the class)
# Say you have lots of generic routes, eg 'about/company', 'about/contact', 'about/license', etc
# Instead of one named route for each, you could use with_options... but even better, define your own function on the map object:
ActionController::Routing::Routes.draw do |map|
  def map.controller_actions(controller, actions)
    actions.each do |action|
      self.send("#{controller}_#{action}", "#{controller}/#{action}", :controller => controller, :action => action)
    end
  end
  map.resources :products, :categories
  map.controller_actions 'about', %w[company privacy license]
end
# Also, see plugin 'static_actions'
# note: likes not having default route so exceptions are raised around resource routes and other valid routes

# Railscast 80
# Simplify views with Rails 2
# Helper improvements... a lot from simply_helpful
= render :partial => 'product', :collection => @products
# becomes
= render :partial => @products # looks for partial named 'product'
# and
= render :partial => 'product', :object => @product
# becomes
= render :partial => @product
# and
= link_to h(product.name), product_path(@product)
# becomes
= link_to h(product.name), @product # generates restufl path to that model
# and
<div class="product"]] >
# becomes
= div_for @product do...end# generates <div id="product_#{id}" class="product"
# and
- form_for :product, :url => products_path
# becomes
- form_for @product # automatically detects if it's new or existing model, and sets appropriate method (post or put)

# Railscast 81
# Fixtures in rails 2
# Will automatically set timestamps to current datetime
# No more id column, will automatically generate from name of fixture.
# foreign keys can use name of other fixture record (use model name only, not fk field name eg, 'project: sample1' not 'project_id: 2')
# Many-to-many no longer requires a join fixture, can declare explicitly using AR association name
couch:
  price: 2.00
  categories: one, two
# Note: has_many :through declarations will require use of join fixture.

# Railscast 82
# Http basic auth in rails 2. See source for more details about authenticate_or_request_with_http_basic()
before_filter :authenticate
def authenticate
  authenticate_or_request_with_http_basic do |username, password|
    # return true or false
    username == 'foo' && password == 'bar'
  end
end

# Railscast 83
# Sexy migrations
rake db:create # creates the db per config
rake db:create:all # creates dev, test, prod, etc
script/generate migration add_description_to_task description:text # add_#_to_# automagically creates migration w/ appropriate declarations.
script/generate migration remove_description_from_task description:text # remove_#_from_# automagic

# Railscast 84
# Cookie-based session store
# Rails 1 stored session data in filesystem. Filecount would build up.
# Rails 2 is now cookie-based. Stores encrypted.
# Constraints: size, bandwidth, user can see contents.

# Railscast 85
# Configuration as yaml
# Assuming sensitive config info like usernames/passwords don't belong in repository.
APP_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/config.yml")
# allows for APP_CONFIG['username']
# To make env-specific...
APP_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/config.yml")[RAILS_ENV] #assuming your yaml file is nested by env's, like database.yml
# in rails 2, put files in app/config/initializers, rails will load all .rb files

# Railscast 86
# Logging variables
# Add a custom method to logger object for handy variable output.
# Uses power of ruby bindings, ability for object to access things outside of its immediate scope.
# uses method local_variables and instance_variables method
# models/product.rb
logger.debug_variables(binding)
# config/initializers/logger_additions.rb
logger = ActiveRecord::Base.logger
def logger.debug_variables(bind)
  vars = eval('local_variables + instance_variables', bind)
  vars.each do |var|
    debug  "#{var} = #{eval(var, bind).inspect}"
  end
end

# Railscast 87
# Generating RSS feeds
# No need for respond_to blocks, will use view file naming to determine formats
# Define a builder file that gives you the xml object
# index.rss.builder
xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0"do
  xml.channel do
    xml.title "Articles"
    xml.description "Lots of articles"
    xml.link formatted_articles_url(:rss)

    for article in @articles
      xml.item do
        xml.title article.name
        xml.description article.content
        xml.pubDate article.created_at.to_s(:rfc822)
        xml.link formatted_article_url(article, :rss)
        xml.guid formatted_article_url(article, :rss)
      end
    end
  end
end
# to link to the feed, in your html view...
# routes gives you formatted_
= link_to 'rss', formatted_models_path(:xml)

# Railscast 88
# Dynamic select menus, keeping it client-side
# Bates does this all in js, using a .js.erb template to generate the javascript
# Creates a 'javascripts' controller to match the /javascripts path, allowing you to
# have dynamic and static javascripts at the same path.

# Railscast 89
# Page Caching
# Three kinds of caching: page, action, fragment. (Don't forget to enable caching in dev env)
# In controller, declare:
caches_page :some_action
# In log you can see the 'cached page' line for the first hit. Physically generates the cached file.
# Subsequent hits don't even touch the Rails stack.
# How to expire? Use sweepers. (create sweepers dir, add to load paths)
config.load_paths << "#{RAILS_ROOT}/app/sweepers"
# app/sweepers/state_sweeper.rb
class StateSweeper < ActionController::Caching::Sweeper
  observe State

  def after_save(state)
    expire_cache(state)
  end

  def after_destroy(state)
    expire_cache(state)
  end

  def expire_cache(state)
    expire_page :controller => 'javascripts', :action => 'dynamic_states', :format => 'js'
  end
end
# states_controller.rb
cache_sweeper :state_sweeper, :only => [:create, :update, :destroy]


# Railscast 90
# Fragment Caching
# Say you have a partial that you want to cache. Use a block:
<% cache 'recent_products'do %>
  some dynamically-generated content
<% end %>
# You'll see 'cached fragment' and 'fragment read' in the log
# The 'recent_products' argument is an identifying name for the fragment that is 'global'
# so it doesn't matter which action/controller is using that fragment. (Default name is the url)
# But the db call that generates the data for the partial might be in an action... so how to cache that?
# Bates puts the find in the view. Makes it clean w/ a specific model method.
# products_controller.rb
cache_sweeper :product_sweeper, :only => [:create, :update, :destroy]
# sweepers/product_sweeper.rb
class ProductSweeper < ActionController::Caching::Sweeper
  observe Product

  def after_save(product)
    expire_cache(product)
  end

  def after_destroy(product)
    expire_cache(product)
  end

  def expire_cache(product)
    expire_fragment 'recent_products'
  end
end


# Railscast 91
# Refactoring log methods
# Bates starts with:
def shipping_price
  total_weight = 0
  line_items.each do |l|
    unless l.for_download?
      total_weight += l.product.weight
    end
  end
  if total_weight == 0
    0.00
  elsif total_weight <= 3
    8.00
  elsif total_weight <= 5
    10.00
  else
    12.00
  end
end
# TIP: look for local variables -- sign of calculating something... can be moved to method.
  # Then, to remove local var that stores calculation... try using array methods.
# TIP: calling multiple model methods? Refactor into one model method.
# And results in:
def shipping_price
  if total_weight == 0
    0.00
  elsif total_weight <= 3  # since this is calling total_weight many times, can use the ||= approach, below
    8.00
  elsif total_weight <= 5  # can refactor this into a shipping weight model, storing this stuff in the db
    10.00
  else
    12.00
  end
end

def total_weight
  @total_weight ||= line_items.to_a.sum(&:weight) # makes that block more concise
end

# models/line_item.rb
def weight
  for_download? ? 0 : product.weight
end

# Railscast 92
# Make Resourceful
# Restful actions are repetitive... try plugin make_resourceful
# products_controller.rb
make_resourceful do
  actions :all

  response_for :show do |format| # controls the rendering behavior of restful action
    format.html
    format.xml { render :xml => current_object.to_xml }
  end
end

private

def current_objects # used by index action
  Product.find(:all, :order => 'name')
end

def current_object # used by single-model loading actions (eg, show)
  @current_object ||= Product.find_by_permalink(params[:id])
end

# For the typical flash handling...
after :update do
  flash[:notice] = "success"
end
# or
after :update_fails do
  #...
end
# or in edit.html.erb
<%= hidden_field_tag '_flash[notice]', "Successfully updated product." ...

# Railscast 93
# Action caching
caches_action :some_action
# Sweeper logic should
expire_action products_path # (use url helper)
# Can also do conditional action caching.
caches_action :index, :cache_path => :index_cache_path.to_proc
def index_cache_path
  if admin?
    '/admin/products'
  else
    '/public/products'
  end
end

# Railscast 94 & 95
# Active Resource
# Simple demo on active resource model.


# Railscast 96
# Git and Rails
#.gitignore
.DS_Store
log/*
tmp/**/*
config/database.yml
db/*.sqlite3
# to add empty tmp, log, vendor dirs, add a blank .gitignore to each directory


# Railscast 97
# Production log analysis
# "Rails Analyzer": production log analyzer. Requires custom logger.
# RAWK. Simple script that parses prod log.


# Railscast 98
# Request Profiling
# Ryan does this on staging to mimic production (caching, etc) yet increase log level (to debug).
# Look at rendering v. db times.
# Rails 2.0 comes w/ profiler: script/performance/request (requires ruby-prof gem)
# Need to create a 'session script' (see test:integration:session rdoc)
# The profiler script generates text and html output.

# Railscast 99
# Complex partials
# (Handle a partial differently depending on what page is rendering the partial)
# Tip: Rails has a current_page? method that  accepts an object as argument
# Tip: Bates uses a helper for things like stylesheets:
def stylesheet(*args)
  content_for(:head) {stylesheet_link_tag(*args)}
end
def title(title)
  content_for(:title) {title}
end
# Consider an article that is displayed in a list and a show page similarly (but different)
# Refactor with helpers, etc. OR... note that Rails 2 allows using partials as layouts,
# so you can have a partial that has a yield
<!-- _article.html.erb -->
<div class="article"]] >
  <h2><%= link_to_unless_current h(article.name), article %></h2>
  <div class="info"]] >
    by <%= article.author > on <%= article.created_at.to_s(:long) %>
    <span class="comments"]] >
      <%= link_to pluralize(article.comments.size, 'Comment'), article %>
    </span>
  </div>
  <div class="content"]] >
    <%= yield %>
  </div>
</div>
<!-- index.html.erb -->
<% for article in @articles %>
  <% render :layout => 'article', :object => article do >
    <p><%=h article.description %></p>
    <p><%= link_to "Read More...", article %></p>
  <% end %>
<% end %>
<!-- show.html.erb -->
<% render :layout => 'article', :object => @article do >
  <% simple_format(h(@article.content)) %>
<% end %>

# Railscast 100
# Five View Tips
# Remove whitespace from erb templates with <%- ... -%>
# Default content_fors with content_for :sidebar ||  render(:partial => '...')
# Use debug with params, request, etc.
# If you have a partial to which you're passing an optional local var, other calls to the partial have to pass that
# local var. Refactor this into a helper, which can set a default value for that local var when you don't need it.
# Use rails hash mixin's reverse_merge! on the hash to combine passed values and defaults, eg:
def display_product(product, locals = {})
  locals.reverse_merge! :show_price => false
  render: partial => product, :locals => locals
end

# Railscast 101
# Refactoring complex helpers
# Got a helper that calls a lot of other functions in the helper file? Refactor it out.
# Bates creates a class to encapsulate that stuff.
# Tip: got member functions that pass common variables around? Use an instance var.
# But, you don't have access to Rails helpers in the generic class, so Bates passes the helper as self
# to the custom helper class, and calls the methods on that.
# application_helper.rb
def render_stars(rating)
  StarsRenderer.new(rating, self).render_stars
end
# helpers/stars_renderer.rb
class StarsRenderer
  def initialize(rating, template)
    @rating = rating
    @template = template
  end

  def render_stars
    content_tag :div, star_images, :class => 'stars'
  end

  private

  def star_images
    (0...5).map do |position|
      star_image(((@rating-position)*2).round)
    end.join
  end

  def star_image(value)
    image_tag "/images/#{star_type(value)}_star.gif", :size => '15x15'
  end

  def star_type(value)
    if value <= 0
      'empty'
    elsif value == 1
      'half'
    else
      'full'
    end
  end

  def method_missing(*args, &block) #use this trick rather than having to always call @template.helper
    @template.send(*args, &block)
  end
end

# Railscast 102
# Autocomplete association
# Using a text field w/autocomplete for categories rather than a long select list.
# product.rb
def category_name
  category.name if category
end
def category_name=(name)
  self.category = Category.find_or_create_by_name(name) unless name.blank?
end
# categories_controller.rb
def index
  @categories = Category.find(:all, :conditions => ['name LIKE ?', "%#{params[:search]}%"])
end
<!-- products/_form.html.erb -->
<p>
  <%= f.label :category_name %>
  <%= text_field_with_auto_complete :product, :category_name, { :size => 15 }, { :url => formatted_categories_path(:js), :method => :get, :param_name => 'search' } %>
</p>
<!-- categories/index.js.erb -->
<%= auto_complete_result @categories, :name >

# Railscast 103
# Site-Wide Announcements
# Use announcements table, start w/ scaffold, add message to layout.
# Uses ajax for hide link. Controller sets sesh var, somefile.js.rjs hides the message.
# Depends on that javascripts controller from prev. episodes.
# models/announcement.rb
defself.current_announcements(hide_time)
  with_scope :find => { :conditions => "starts_at <= now() AND ends_at >= now()" } do
    if hide_time.nil?
      find(:all)
    else
      find(:all, :conditions => ["updated_at > ? OR starts_at > ?", hide_time, hide_time])
    end
  end
end
# application_helper.rb
def current_announcements
  @current_announcements ||= Announcement.current_announcements(session[:announcement_hide_time])
end
# javascripts_controller.rb
def hide_announcement
  session[:announcement_hide_time] = Time.now
end
# hide_announcement.js.rjs
page[:announcement].hide
# routes.rb
map.connect ":controller/:action.:format"

# Railscast 104
# Ex notifications
# Covers ex notifier and also Exception Logger plugin

# Railscast 105
# Gitting Rails
# Note that Rails2 has script/dbconsole (runs db client app)

# Railscast 106
# Time Zones
rake time:zones:* (all, local, us)
# environment.rb
config.time_zone = "Pacific Time (US & Canada)"# specifices server time. db stores as UTC
Product.first.releasd_at_before_type_cast # Note _before_type_cast
# user.rb
# include attribute Time Zone (string)
# view...
f.time_zone_select, :time_zone, TimeZone.us_zones
# cntrlr...
before_filter :set_user_time_zone
def set_user_time_zone
  Time.zone = current_user.time_zone if logged_in?
end

# Railscast 107
# Migrations in Rails 2
# alter table now has a change table that takes a block
# you can now do :null => true when changing columns that are :null => false

# Railscast 108
# Named Scope
named_scope :cheap, :conditions => {:price => 0..5}
# Multiple scopes can be chained
# Accepts a lambda (helps get around the static nature of the named_scope declaration)
#  Also allows passing argument to the named_scope method
#  And allows you to set a default val if no arg is provided (lambda {|*args|})
# Can chain across associations
# Can use associated model attribute as part of scope criteria, eg:
named_scope :visible, :include => :category, :conditions => {'category.visible = ?' => true}
# Can append all/first/last to named_scope methods, eg:
Product.recent.all(:order => 'released_at')

# Railscast 109
# Tracking model changes w/ Rails 2
p.changed? # did any attribute change?
p.attrName_was # what was the previous value?
p.attrName_change # what is the new value?
p.changed # array of changed attribute names
p.changes # hash of changed attribute names w/ previous, current value
# new ar is smart enough to generate queries updating only changed attributes
# initializer...
ActiveRecord::Base.partial_updates = true
# Gotchas: AR changes only aware via accessors.
p.name.upcase!
p.name.changed? # false
p.save # no db update
p.name_will_change! # force the changed awareness

# Railscast 110
# Gem dependencies
config.gem "RedCloth", :version => ">= 3.0.4", :source => 'http://asdasd...'
config.gem "aws-s3", :lib => 'aws/s3'
rake gems # list gem dependencies
rake gems:install # installs any missing gem dependencies
rake gems:unpack or gems:unpack:dependencies # unpacks gem into vendor
rake gems:build # builds native extensions (?)

# Railscast 111
# Advanced Search Form
# Got an advanced search form with tons of options?
# Create a search model and controller. Assuming form has parameters
# :keywords, :minimum_price, :maximum_price, :category_id, the model might be:
# models/search.rb
def products
  @products ||= find_products
end

private

def find_products
  Product.find(:all, :conditions => conditions)
end

def keyword_conditions
  ["products.name LIKE ?", "%#{keywords}%"] unless keywords.blank?
end

def minimum_price_conditions
  ["products.price >= ?", minimum_price] unless minimum_price.blank?
end

def maximum_price_conditions
  ["products.price <= ?", maximum_price] unless maximum_price.blank?
end

def category_conditions
  ["products.category_id = ?", category_id] unless category_id.blank?
end

def conditions
  [conditions_clauses.join(' AND '), *conditions_options]
end

def conditions_clauses
  conditions_parts.map { |condition| condition.first }
end

def conditions_options
  conditions_parts.map { |condition| condition[1..-1] }.flatten
end

def conditions_parts
  private_methods(false).grep(/_conditions$/).map { |m| send(m) }.compact
end

# Railscast 112
# Anonymous Scopes
# Can refactor the AR stuff in the query strategy above. Once way is to add named_scopes
# to the product model, which can then be chained, eg:
named_scope :with_keywords, :conditions => lambda { |value| {:conditions => ['name LIKE ?', "%#{value}%"]} }
named_scope :with_price_gt, :conditions => lambda { |value| {:conditions => ['price >= ?', value]} }
# etc
# Which works, but is kinda messy: search-related scopes are littering the Product model.
# Instead, try anonymous scopes:
def find_products
  Product.scoped(:conditions => ...).scoped(:conditions => ...) # just to illustrate
end
# really
def find_products
  scope = Product.scoped({})
  scope = scope.scoped, :conditions => ["products.name LIKE ?", "%#{keywords}%"] unless keywords.blank?
  scope = scope.scoped, :conditions => ["products.price >= ?", minimum_price] unless minimum_price.blank?
  # etc
  scope
end
# but, a little still messy. You can clean it up (a little) by defining a named scope called conditions.
# config/initializers/global_named_scopes.rb
class ActiveRecord::Base
  named_scope :conditions, lambda { |*args| {:conditions => args} }
end
# models/search.rb
def find_products
  scope = Product.scoped({})
  scope = scope.conditions "products.name LIKE ?", "%#{keywords}%"unless keywords.blank?
  scope = scope.conditions "products.price >= ?", minimum_price unless minimum_price.blank?
  scope = scope.conditions "products.price <= ?", maximum_price unless maximum_price.blank?
  scope = scope.conditions "products.category_id = ?", category_id unless category_id.blank?
  scope
end

# Railscast 113
# Contributing to Rails with Git
# TIP: returning w/ block! cool...
# Also see http://guides.rails.info/contributing_to_rails.html
# run tests
rake test
cd activerecord
rake mysql:build_databases
rake test_mysql
rake test_mysql TEST='test/cases/named_scope_test.rb'

# make changes on branch
git checkout -b named_scope_with_bang
git commit -a -m "named_scope with bang"

# pull recent changes and apply to branch
git checkout master
git pull
git checkout named_scope_with_bang
git rebase master

# make patch
git format-patch master --stdout > ~/named_scope_with_bang.diff

# apply patch
curl http://somewhere/something.diff | git am


# Railscast 114
# Endless page w/ pagination and ajax.
# products_controller.rb
def index
  @products = Product.paginate(:page => params[:page], :per_page => 15)
  # possibly a respond_to block
end
# index.js.rjs
page.insert_html :bottom, :products, :partial => @products
if @products.total_pages > @products.current_page
  page.call 'checkScroll'
else
  page[:loading].hide
end
# application_helper.rb
def javascript(*args)
  content_for(:head) { javascript_include_tag(*args) }
end
# index.html.erb
<% title "Products" %>
<% javascript :defaults, 'endless_page' %>

<div id="products"]] >
  <%= render :partial => @products %>
</div>
<p id="loading">Loading more page results...</p>
# endless_page.js
var currentPage = 1;
function checkScroll() {
  if (nearBottomOfPage()) {
    currentPage++;
    new Ajax.Request('/products.js?page=' + currentPage, {asynchronous:true, evalScripts:true, method:'get'});
  } else {
    setTimeout("checkScroll()", 250);
  }
}
function nearBottomOfPage() {
  return scrollDistanceFromBottom() < 150;
}
function scrollDistanceFromBottom(argument) {
  return pageHeight() - (window.pageYOffset + self.innerHeight);
}
function pageHeight() {
  return Math.max(document.body.scrollHeight, document.body.offsetHeight);
}
document.observe('dom:loaded', checkScroll);


# Railscast 115
# Caching in Rails 2.1
# page, action, fragment caching... now general cache.
Rails.cache.write('date', Date.today)
Rails.cache.read('date')
Rails.cache.delete('date')
Rails.cache.fetch('time') { Time.now } # lookup or create
# How to use? Example:
# models/category.rb
defself.all_cached
  Rails.cache.fetch('Category.all') { all }
end
# config/environments/production.rb
config.cache_store = :memory_store
config.cache_store = :file_store, '/path/to/cache'
config.cache_store = :mem_cache_store
config.cache_store = :mem_cache_store, { :namespace => 'storeapp' }
config.cache_store = :mem_cache_store, '123.456.78.9:1001', '123.456.78.9:1002'
# can create a separate cache store at runtime:
cache = ActiveSupport::Cache.lookup_store(:mem_cache_store)
cache.fetch('time') { Time.now }
# Rails gives each AR object a cache_key
c = Category.first
c.cache_key # => "categories/1-20080622195243"


# Railscast 116
# Selenium, http://selenium-ide.openqa.org
# 1) Start app in test env
# 2) Start selenium ide and record
# 3) Do shit.
# 4) Right click shit to add tests to selenium ide
# Selenium on Rails plugin! (github.com/ryanb/selenium-on-rails)
script/generate selenium destroy_product.rsel
# test/selenium/destroy_product.rsel
setup :fixtures => :all
product = Product.first
open '/'
click "css=#product_#{product.id} a:contains('Destroy')"
assert_confirmation('*')
wait_for_element_present "css=#flash_notice"
assert_element_not_present "css=#product_#{product.id}"
refresh
assert_element_not_present "css=#product_#{product.id}"
# Run the test via /selenium
# Can also run via rake, requires config file (cp vendor/plugins/selenium-on-rails/config.yml.example config/selenium.yml)
# config/selenium.yml
environments:
  - test
browsers:
  firefox: '/Applications/Firefox.app/Contents/MacOS/firefox-bin'
  safari: '/Applications/Safari.app/Contents/MacOS/Safari'
# And then...
rake test:acceptance
# Awesome...


# Railscast 117
# Semistatic pages
# simple_format() helper
# RedCloth for textile (v3.301)... textilize()
# or RedCloth.new(text).to_html if textilize() line breaks are in your way
# Not much new here

# Railscast 118
# Liquid Templates
# Provides a templating language to control the ability to execute dynamic
# code within a piece of content.
# Filters, etc. See documentation.
# TIP: gem server --> status up an rdoc server locally

# Railscast 119
# Session-based models
# When faced with a bunch of session data and methods that use the session,
# or multiple locations for certain session-based logic,
# try wrapping the session, eg, with UserSession. Non-AR model. Initializer is
# passed a reference to the session.
# models/user_session.rb
class UserSession
  def initialize(session)
    @session = session
    @session[:comment_ids] ||= []
  end

  def add_comment(comment)
    @session[:comment_ids] << comment.id
  end

  def can_edit_comment?(comment)
    @session[:comment_ids].include?(comment.id) && comment.created_at > 15.minutes.ago
  end
end
# controllers/application.rb
def user_session
  @user_session ||= UserSession.new(session)
end
helper_method :user_session
# view...
<% if user_session.can_edit_comment? comment %>
  <p><%= link_to "Edit", edit_comment_path(comment) %></p>
<% end >


# Railscast 120
# Thinking Sphinx, plugin for Sphinx, a full-text search engine
# Install Sphinx, MySQL or Postgres (no sqlite).
# in model:
define_index do
  indexes content # attribute name
  indexes :name, :sortable => true# Necessary for search :order option.
                                   # Be sure to use symbol for 'name', 'id' due to scope conflict
  indexes comments.content, :as => :comment_content
  indexes [author.first_name, author.last_name], :as => :author_name
  has author_id, created_at # Necessary for search :conditions option
end
# in cntlr:
Article.search params[:searchquery]
# :include => :author
# :conditions => { :created_at => 1.week.ago.to_i..Time.now.to_i }
# :order => :name
# :field_weights => { :name => 20, :content => 10, :author_name => 5 }
# :match_mode => :boolean
# :page => 1, :per_page => 20

# and start sphinx:
rake thinking_sphinx:index # don't forget to reindex after making declarative changes
rake thinking_sphinx:start

# Note: Look at "delta indexing" for "real-time" search capability (sans reindexing)


# Railscast 121
# Non-activerecord models
# When you need to create urls for a non-ar model, override to_param, but link_to
# just needs the object and will determine the appropriate controller.
# Bates shows how to mimic AR-like methods on a non-AR class.
# models/letter.rb
class Letter
  attr_reader :char
  defself.all
    ('A'..'Z').map { |c| new(c) }
  end
  defself.find(param)
    all.detect { |l| l.to_param == param } || raise(ActiveRecord::RecordNotFound)
  end
  def initialize(char)
    @char = char
  end
  def to_param
    @char.downcase
  end
  def products
    Product.find(:all, :conditions => ["name LIKE ?", @char + '%'], :order => "name")
  end
end
# letters_controller.rb
def index
  @letters = Letter.all
end
def show
  @letter = Letter.find(params[:id])
end
#letters/index.html.erb
<% for letter in @letters %>
  <%= link_to letter.char, letter %>
<% end >
#letters/show.html.erb
<p><%= link_to "Select a Letter", letters_path %></p>
<%= render :partial => @letter.products >

# Railscast 122
# Passenger in development
# Simple overview of installing and running passenger. (OSX? Passenger Prefpane)

# Railscast 123
# Subdomains w/ subdomain_fu
# Edit etc/hosts to reach subdomains, PAC file in web browser prefs.
ServerAlias *.some.domain.com
request.subdomains # returns array of subdomains.
# subdomain_fu provides...
current_subdomain()
# subdomain_fu likes dev server tld domain to be .localhost by default.
SubdomainFu.tld_sizes = {:development => 0, # localhost. change to customize (eg, something.local)
                         :test => 0,
                         :production => 1}
# routes.rb
map.something '', :controller => 'blogs', :action => 'show', :conditions => { :subdomain => /.+/ }
# controller...
Blog.find_by_subdomain(current_subdomain)
# view links...
blog_root_url(:subdomain => blog.subdomain)

# protecting links w/ ids...
# define before filter application controller...
def load_blog
  @current_blog = Blog.find_by_subdomain(current_subdomain)
  ...
end
# controllers...
@current_subdomain.articles.find(params[:id])

# sharing sessions between subdomains:
ActionController::Base.session_options[:session_domain] = '.blog.local'


# Railscast 124
# Beta invitations
# models/invitation.rb
belongs_to :sender, :class_name => 'User'
has_one :recipient, :class_name => 'User'
validates_presence_of :recipient_email
validate :recipient_is_not_registered
validate :sender_has_invitations, :if => :sender
before_create :generate_token
before_create :decrement_sender_count, :if => :sender
private
def recipient_is_not_registered
  errors.add :recipient_email, 'is already registered'if User.find_by_email(recipient_email)
end
def sender_has_invitations
  unless sender.invitation_limit > 0
    errors.add_to_base 'You have reached your limit of invitations to send.'
  end
end
def generate_token
  self.token = Digest::SHA1.hexdigest([Time.now, rand].join)
end
def decrement_sender_count
  sender.decrement! :invitation_limit
end
# models/user.rb
validates_presence_of :invitation_id, :message => 'is required'
validates_uniqueness_of :invitation_id
has_many :sent_invitations, :class_name => 'Invitation', :foreign_key => 'sender_id'
belongs_to :invitation
before_create :set_invitation_limit
attr_accessible :login, :email, :name, :password, :password_confirmation, :invitation_token
def invitation_token
  invitation.token if invitation
end
def invitation_token=(token)
  self.invitation = Invitation.find_by_token(token)
end
private
def set_invitation_limit
  self.invitation_limit = 5
end
# invitation_controller.rb
def new
  @invitation = Invitation.new
end
def create
  @invitation = Invitation.new(params[:invitation])
  @invitation.sender = current_user
  if @invitation.save
    if logged_in?
      Mailer.deliver_invitation(@invitation, signup_url(@invitation.token))
      flash[:notice] = "Thank you, invitation sent."
      redirect_to projects_url
    else
      flash[:notice] = "Thank you, we will notify when we are ready."
      redirect_to root_url
    end
  else
    render :action => 'new'
  end
end
# users_controller.b
def new
  @user = User.new(:invitation_token => params[:invitation_token])
  @user.email = @user.invitation.recipient_email if @user.invitation
end
# routes.rb
map.signup '/signup/:invitation_token', :controller => 'users', :action => 'new'
# models/mailer.rb
def invitation(invitation, signup_url)
  subject    'Invitation'
  recipients invitation.recipient_email
  from       'foo@example.com'
  body       :invitation => invitation, :signup_url => signup_url
  invitation.update_attribute(:sent_at, Time.now)
end


# Railscast 125
# Dynamic layouts. Eg, different layouts for different, say, subdomains.
# application.rb
layout :set_layout
def load_blog
  @current_blog = Blog.find_by_subdomain(current_subdomain)
  if @current_blog.nil?
    flash[:error] = "Blog invalid"
    redirect_to root_url
  end
end
def set_layout
  (@current_blog && @current_blog.layout_name) || 'application'
end
# For customized layouts, Bates recommends template language such as Liquid.
# app/views/layouts/custom.erb.html
<%= Liquid::Template.parse(@current_blog.custom_layout_content).render('page_content' => yield, 'page_title' => yield(:title)) ->


# Railscasts 126
# Populating a database
# This must be before seed.rb
# Create a rake task... and use Bates 'populator' gem and 'faker' gem
namespace :db do
  desc "Erase and fill db"
  task :populate => :environment do
    require'populator'
    [Category, Product, Person].each(&:delete_all)
    Category.populate 20do |c|
      c.name = Populator.words(1..3).titleize
      Product.populate 10..100do |product|
        product.category_id = category.id
        product.name = Populator.words(1..5).titleize
        product.description = Populator.sentences(2..10)
        product.price = [4.99, 19.95, 100]
        product.created_at = 2.years.ago..Time.now
      end
    end
    Person.populate 100do |person|
      person.name    = Faker::Name.name
      person.company = Faker::Company.name
      person.email   = Faker::Internet.email
      person.phone   = Faker::PhoneNumber.phone_number
      person.street  = Faker::Address.street_address
      person.city    = Faker::Address.city
      person.state   = Faker::Address.us_state_abbr
      person.zip     = Faker::Address.zip_code
    end
  end
end


# Railscast 127
# Rake in background. Can execute rake tasks from application.
# Ideal for infrequent tasks, long running tasks. Be sure you have strict authorization in place!
# controllers/application.rb
def call_rake(task, options = {})
  options[:rails_env] ||= Rails.env
  args = options.map { |n, v| "#{n.to_s.upcase}='#{v}'" }
  system "/usr/bin/rake #{task} #{args.join(' ')} --trace 2>&1 >> #{Rails.root}/log/rake.log &"
end
# mailings_controller.rb
def deliver
  call_rake :send_mailing, :mailing_id => params[:id].to_i
  flash[:notice] = "Delivering mailing"
  redirect_to mailings_url
end
# lib/tasks/mailer.rake
desc "Send mailing"
task :send_mailing => :environment do
  mailing = Mailing.find(ENV["MAILING_ID"])
  mailing.deliver
end
# models/mailing.rb
def deliver
  sleep 10# placeholder for sending email
  update_attribute(:delivered_at, Time.now)
end

# Railscast 128
# Long running tasks: Starling and Workling
# http://rubypond.com/blog/the-complete-guide-to-setting-up-starling
starling -d -P tmp/pids/starling.pid -q log/
script/workling_starling_client start
# config/environments/development.rb
Workling::Remote.dispatcher = Workling::Remote::Runners::StarlingRunner.new
# mailings_controller.rb
MailingsWorker.async_send_mailing(:mailing_id => params[:id])
# app/workers/mailings_worker.rb
class MailingsWorker < Workling::Base
  def send_mailing(options)
    mailing = Mailing.find(options[:mailing_id])
    mailing.deliver
  end
end


# Railscast 129
# Custom daemon
# Consider scheduled mailings (bg process starts at scheduled time)
# Other daemons: BackgroundJob (BJ), BackgrounDRb (not rec'd), Background Fu
# Demons gem, demon generator (plugin)
gem install daemons
script/plugin install git://github.com/dougal/daemon_generator.git
script/generate daemon mailer # creates lib/mailer.rb, lib/mailer_ctl, config/daemons.yml, and scripts/daemons
RAILS_ENV=development lib/daemons/mailer_ctl start # start the daemon
# lib/daemons/mailer.rb
while($running) do
  mailing = Mailing.next_for_delivery
  if mailing
    mailing.deliver
  else
    sleep 15
  end
end
# mailings_controller.rb
def deliver
  Mailing.update(params[:id], :scheduled_at => Time.now)
  flash[:notice] = "Delivering mailing"
  redirect_to mailings_url
end
# models/mailing.rb
defself.next_for_delivery
  Mailing.first(:conditions => ["delivered_at IS NULL AND scheduled_at <= ?", Time.now.utc], :order => "scheduled_at")
end
def deliver
  update_attribute(:scheduled_at, nil)
  sleep 10# placeholder for sending email
  update_attribute(:delivered_at, Time.now)
end


# Railscast 130
# Monitoring with God, a gem (alternative to monit) http://god.rubyforge.org/
# May need to alter paths in script/workling_starling_client config file
# Lots of nice stuff to control behavior of monitoring.
# http://railscasts.com/episodes/130-monitoring-with-god
# But note that it may leak memory or fail to control processes.

# Railscast 131
# Going back
# cart_items_controller.rb
def create
  current_cart.cart_items.create!(params[:cart_item])
  flash[:notice] = "Product added to cart"
  redirect_to :back
end
# or
def create
  current_cart.cart_items.create!(params[:cart_item])
  flash[:notice] = "Product added to cart"
  session[:last_product_page] = request.env['HTTP_REFERER'] || products_url
  redirect_to current_cart_url
end
# carts/show.html.erb
<% if session[:last_product_page] %>
  <%= link_to "Continue Shopping", session[:last_product_page] %> |
<% end ->

# Railscast 132
# Helpers outside views
# in a model...
include ActionView::Helpers::TextHelper
# but not recommended, adds lots of methods that you might not need, or requires additional dependencies
# you don't really need...
h = ActionController::Base.helpers # returns a helper proxy object (doesn't work w/ url helpers)
h.pluralize(...)
# in a controller... try using the @template instance variable (not necessarily a best practice)
@template.link_to '...'

# Railscast 133
# Capistrano tasks
# Capistrano has some 'hidden' built-in tasks for Rails:
#  deploy:update_code
#  deploy:symlink
#  deploy:restart, start, stop, migrate(?)
# Override start/stop/restart with tasks specific to passenger.
# Default dir structure:
# myapp/releases
# myapp/current -> ...
# myapp/shared
namespace :deploy do
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
  task :my_custom_task do
    # eg, linking asset dirs, etc
    # system "..." # execute the command on the local machine
  end
end
after 'deploy:update_code', 'deploy:my_custom_task'


# Railscast 134
# Paperclip
script/generate paperclip product photo
rake db:migrate
# models/product.rb
has_attached_file :photo, :styles => { :small => "150x150>" },
                  :url  => "/assets/products/:id/:style/:basename.:extension",
                  :path => ":rails_root/public/assets/products/:id/:style/:basename.:extension"
validates_attachment_presence :photo
validates_attachment_size :photo, :less_than => 5.megabytes
validates_attachment_content_type :photo, :content_type => ['image/jpeg', 'image/png']


# Railscast 135
# Making a Gem (w/ echoe)
# hoe, newgem, bones, gemhub, echoe
sudo gem install echoe
mkdir -p uniquify/lib
touch README.rdoc Rakefile lib/uniquify.rb
rake -T
rake manifest
rake install
rake build_gemspec
git init
git add .
git commit -m "initial commit"
git remote add origin git@github.com:ryanb/uniquify.git
git push
touch CHANGELOG
touch init.rb
# Rakefile
require'rubygems'
require'rake'
require'echoe'
Echoe.new('uniquify', '0.1.0') do |p|
  p.description    = "Generate a unique token with Active Record."
  p.url            = "http://github.com/ryanb/uniquify"
  p.author         = "Ryan Bates"
  p.email          = "ryan@railscasts.com"
  p.ignore_pattern = ["tmp/*", "script/*"]
  p.development_dependencies = []
end
Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }
# lib/uniquify.rb
module Uniquify
  defself.included(base)
    base.extend ClassMethods
  end
  def ensure_unique(name)
    begin
      self[name] = yield
    endwhileself.class.exists?(name => self[name])
  end
  module ClassMethods
    def uniquify(*args, &block)
      options = { :length => 8, :chars => ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a }
      options.merge!(args.pop) if args.last.kind_of? Hash
      args.each do |name|
        before_create do |record|
          if block
            record.ensure_unique(name, &block)
          else
            record.ensure_unique(name) do
              Array.new(options[:length]) { options[:chars].to_a[rand(options[:chars].to_a.size)] }.join
            end
          end
        end
      end
    end
  end
end
class ActiveRecord::Base
  include Uniquify
end
# init.rb
require'uniquify'

# Railscast 136
# JQuery
# One option: jrails plugin... but jQuery is particularly for "unobtrusive js"
# Need to explicitly set accept header so rails responds_to with .js
// public/javascripts/application.js
jQuery.ajaxSetup({
  'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
})
jQuery.fn.submitWithAjax = function() {
  this.submit(function() {
    $.post(this.action, $(this).serialize(), null, "script");
    returnfalse;
  })
  return this;
};
$(document).ready(function() {
  $("#new_review").submitWithAjax();
})
// views/reviews/create.js.erb
$("#new_review").before('<div id="flash_notice"><%= escape_javascript(flash.delete(:notice)) %></div>');
$("#reviews_count").html("<%= pluralize(@review.product.reviews.count, 'Review') %>");
$("#reviews").append("<%= escape_javascript(render(:partial => @review)) %>");
$("#new_review")[0].reset();


# Railscast 137
# Memoization in Rails 2.2.2
# in model...
extend ActiveSupport::Memoizable
memoize :filesize
def filesize
  # some expensive operation
  sleep 2
  12345
end
# Works w/ methods that take an argument too.
# Can pass true as last arg to get non-memoized return.

# Railscast 138
# i18n in Rails 2.2.2
# set up key/values in config/locales/*.yml
# Use I18N.translate() shorthand:
= t 'welcome.paragrph'
# sessions_controller.rb
flash[:notice] = t('flash.login')
# Control lanugage via controller before_filter:
before_filter :set_user_language
def set_user_language
  I18n.locale = current_user.language if logged_in?
end
# See the .yml doco link for lots of i18n templates, eg money/date formatting

# Railscast 139
# Nested Resources
# routes.rb
ActionController::Routing::Routes.draw do |map|
  map.resources :articles, :has_many => :comments, :shallow => true# shallow lets you /comments/1/edit for example.
  map.resources :comments, :only => [:index] # that'll give you /comments
  map.root :articles
end
# So now you can /articles/1/comments/2 and also /comments/2/edit and so on.

# Railscast 140
# Rails 2.2 Extras
Product.find_by_price!(3) # => Custom finders w/ bang now raise RecordNotFound Exception
Product.find_last_by_price(4.99)
Product.all(:joins => :category, :conditions => { :categories => { :name => 'Clothing' } })
# application_helper.rb
# Used to be concat content_tag(:div, capture(&block), :class => 'admin'), block.binding
def admin_area(&block)
  if admin?
    concat content_tag(:div, capture(&block), :class => 'admin')
  end
end
# In a view... (See Railscast #40 blocks in view)
admin_area do
 = link_to "Edit", edit_product_path(@product)
 = link_to "Destroy", @product, :confirm => 'Are you sure?', :method => :delete
end
# application_helper.rb
def admin_area(&block)
  if admin?
    concat content_tag(:div, capture(&block), :class => 'admin')
  end
end


# Railscast 141
# PayPal Basics
# Simple illustration of using the PayPal Sandbox to create buyer and seller accounts,
# and generating the paypal url to link to.
= link_to "Checkout", @cart.paypal_url(products_url)
# models/cart.rb
def paypal_url(return_url)
  values = {
    :business => 'seller_1229899173_biz@railscasts.com',
    :cmd => '_cart',
    :upload => 1,
    :return => return_url,
    :invoice => id
  }
  line_items.each_with_index do |item, index|
    values.merge!({
      "amount_#{index+1}" => item.unit_price,
      "item_name_#{index+1}" => item.product.name,
      "item_number_#{index+1}" => item.id,
      "quantity_#{index+1}" => item.quantity
    })
  end
  "https://www.sandbox.paypal.com/cgi-bin/webscr?" + values.to_query
end


# Railscast 142
# PayPal Notifications (IPN)
# How to clear the cart on your app after the paypal purchase is complete?
# Order Management Integration Guide (by PayPal) lists the parameters it can send.
# Create PaymentNotification resource w/ :create endpoint.
# Since paypal can't post to localhost:3000, you can grab the transaction id from the
# paypal payment confirmation screen and create a fake http request w/ curl to your app.
payment_notification params:text cart_id:integer status:string transaction_id:string create
# payment_notifications_controller.rb
protect_from_forgery :except => [:create]
def create
  PaymentNotification.create!(:params => params, :cart_id => params[:invoice], :status => params[:payment_status], :transaction_id => params[:txn_id])
  render :nothing => true
end

# models/payment_notification.rb
belongs_to :cart
serialize :params
after_create :mark_cart_as_purchased
private
def mark_cart_as_purchased
  if status == "Completed"
    cart.update_attribute(:purchased_at, Time.now)
  end
end

# controllers/application.rb
def current_cart
  if session[:cart_id]
    @current_cart ||= Cart.find(session[:cart_id])
    session[:cart_id] = nilif @current_cart.purchased_at
  end
  if session[:cart_id].nil?
    @current_cart = Cart.create!
    session[:cart_id] = @current_cart.id
  end
  @current_cart
end

# models/cart.rb
def paypal_url(return_url, notify_url)
  values = {
    :business => 'seller_1229899173_biz@railscasts.com',
    :cmd => '_cart',
    :upload => 1,
    :return => return_url,
    :invoice => id,
    :notify_url => notify_url
  }
  line_items.each_with_index do |item, index|
    values.merge!({
      "amount_#{index+1}" => item.unit_price,
      "item_name_#{index+1}" => item.product.name,
      "item_number_#{index+1}" => item.id,
      "quantity_#{index+1}" => item.quantity
    })
  end
  "https://www.sandbox.paypal.com/cgi-bin/webscr?" + values.to_query
end
# In the view:
= link_to "Checkout", @cart.paypal_url(products_url, payment_notifications_url

# Railscast 143
# PayPal Security
# Create an ssl certificate:
mkdir certs
cd certs
openssl genrsa -out app_key.pem 1024
openssl req -new -key app_key.pem -x509 -days 365 -out app_cert.pem
# Add cert to paypal profile; download paypal public cert and place within app:
mv ~/Downloads/paypal_cert_pem.txt paypal_cert.pem
script/generate nifty_config
# Use form to post to paypal url, include hidden fields 'cmd' and 'encrypted' fields.
# cart view
= hidden_field_tag :cmd, '_s-xclick'
= hidden_field_tag :encrypted, @cart.paypal_encrypted(products_url, payments_notification_url)
# models/cart.rb
def paypal_encrypted(return_url, notify_url)
  values = {
    :business => APP_CONFIG[:paypal_email],
    :cmd => '_cart',
    :upload => 1,
    :return => return_url,
    :invoice => id,
    :notify_url => notify_url,
    :cert_id => APP_CONFIG[:paypal_cert_id]
  }
  line_items.each_with_index do |item, index|
    values.merge!({
      "amount_#{index+1}" => item.unit_price,
      "item_name_#{index+1}" => item.product.name,
      "item_number_#{index+1}" => item.id,
      "quantity_#{index+1}" => item.quantity
    })
  end
  encrypt_for_paypal(values)
end

PAYPAL_CERT_PEM = File.read("#{Rails.root}/certs/paypal_cert.pem")
APP_CERT_PEM = File.read("#{Rails.root}/certs/app_cert.pem")
APP_KEY_PEM = File.read("#{Rails.root}/certs/app_key.pem")

def encrypt_for_paypal(values)
  signed = OpenSSL::PKCS7::sign(OpenSSL::X509::Certificate.new(APP_CERT_PEM), OpenSSL::PKey::RSA.new(APP_KEY_PEM, ''), values.map { |k, v| "#{k}=#{v}" }.join("\n"), [], OpenSSL::PKCS7::BINARY)
  OpenSSL::PKCS7::encrypt([OpenSSL::X509::Certificate.new(PAYPAL_CERT_PEM)], signed.to_der, OpenSSL::Cipher::Cipher::new("DES3"), OpenSSL::PKCS7::BINARY).to_s.gsub("\n", "")
end

# Then how to secure the payment notification from being spoofed? You can use a postback scheme, or provide secret.
= hidden_field_tag :encrypted, @cart.paypal_encrypted(products_url, payments_notification_url(:secret => 'eh'))
# Check for secret, and that other params match when marking cart as purchased
# models/payment_notification.rb
def mark_cart_as_purchased
  if status == "Completed" && params[:secret] == APP_CONFIG[:paypal_secret] &&
      params[:receiver_email] == APP_CONFIG[:paypal_email] &&
      params[:mc_gross] == cart.total_price.to_s && params[:mc_currency] == "USD"
    cart.update_attribute(:purchased_at, Time.now)
  end
end
# Use external, environment-dependent config file (see ep #85 notes) to keep stuff out of the app.
# app_config.yml
development:
  paypal_email: seller_1229899173_biz@railscasts.com
  paypal_secret: foobar
  paypal_cert_id: WKKX2FSCFDB8C
  paypal_url: "https://www.sandbox.paypal.com/cgi-bin/webscr"


# Railscast 144
# Active Merchant Basics (using pp as a payment gateway)
# Just covers the basics of the AM api using a simple script.

# Railscast 145
# Creating a cart, tying to shopping cart, integrating validations.
# order.rb
def validate_card
  unless credit_card.valid?
    credit_card.errors.full_messages.each do |message|
      errors.add_to_base message
    end
  end
end
def credit_card
  @credit_card ||= ActiveMerchant::Billing::CreditCard.new(
    :type               => card_type,
    :number             => card_number,
    :verification_value => card_verification,
    :month              => card_expires_on.month,
    :year               => card_expires_on.year,
    :first_name         => first_name,
    :last_name          => last_name
  )
end
def purchase
   response = GATEWAY.purchase(price_in_cents, credit_card, purchase_options)
   transactions.create!(:action => "purchase", :amount => price_in_cents, :response => response)
   cart.update_attribute(:purchased_at, Time.now) if response.success?
   response.success?
 end
# OrderTransaction (order_id:int, action:string, amount:int, success:bool authorization:string message:string params:text)
class OrderTransaction < ActiveRecord::Base
  belongs_to :order
  serialize :params
  def response=(response)
    self.success       = response.success?
    self.authorization = response.authorization
    self.message       = response.message
    self.params        = response.params
  rescue ActiveMerchant::ActiveMerchantError => e
    self.success       = false
    self.authorization = nil
    self.message       = e.message
    self.params        = {}
  end
end

# Railscast 146
# Paypal Express Checkout
# Straightforward example...
# NOTE: custom REST routes with:
map.resources :orders, :new => {:express => :get} # maps to OrdersController#express


# Railscast 147
# Sortable drag n drop lists
# Model should have position attribute, include prototype in view
# Make sure containin dom element, eg, ul, has id. Child dom elements have id, eg modelname_id
  # content_tag_for(:li, object)
# Use rails sortable element helper:
  # sortable_element("parentdomid", :url => sort_models_path, :handle => 'somedomclassactsasUIdraghandle')
# routes.rb
map.resources :faqs, :collection => { :sort => :post }

# faqs_controller.rb
def sort
  params[:faqs].each_with_index do |id, index|
    Faq.update_all(['position=?', index+1], ['id=?', id])
  end
  render :nothing => true
end

# models/faq.rb
class Faq < ActiveRecord::Base
  acts_as_list
end


# Railscast 148
# Application templates
rails store -m auth_template.rb # create store app with template
# Can create template scripts to create base rails app. Comes with methods,
# like run, git, file, generate, gem, rake, plugin, route etc
# Conditionals too:
if yes?("Do you want to do X?")
  # commands
end
# Or take user input:
name = ask("Name of plugin?")
# And load other templates:
load_template "http://github.../template.rb"# url or local path
# Example:
# base_template.rb
run "echo TODO > README"
generate :nifty_layout
gem 'RedCloth', :lib => 'redcloth'
gem 'mislav-will_paginate', :lib => 'will_paginate', :source => 'http://gems.github.com'
rake "gems:install"
if yes?("Do you want to use RSpec?")
  plugin "rspec", :git => "git://github.com/dchelimsky/rspec.git"
  plugin "rspec-rails", :git => "git://github.com/dchelimsky/rspec-rails.git"
  generate :rspec
end
git :init
file ".gitignore", <<-END
.DS_Store
log/*.log
tmp/**/*
config/database.yml
db/*.sqlite3
END
run "touch tmp/.gitignore log/.gitignore vendor/.gitignore"
run "cp config/database.yml config/example_database.yml"
git :add => ".", :commit => "-m 'initial commit'"
# auth_template.rb
load_template "/Users/rbates/code/base_template.rb"
name = ask("What do you want a user to be called?")
generate :nifty_authentication, name
rake "db:migrate"
git :add => ".", :commit => "-m 'adding authentication'"
generate :controller, "welcome index"
route "map.root :controller => 'welcome'"
git :rm => "public/index.html"
git :add => ".", :commit => "-m 'adding welcome controller'"


# Railscast 149
# Rails engines
# Rails 2.3 has certain load paths sets for plugins that gives us much of the same functionality
# as the ol' Rails Engines.
script/generate plugin blogify
# Copy your app/ stuff into plugins/blogify
# Copy your config/routes.rb into plugins/blogify/config
# Copy your migrations into plugins/blogify/db/migrations
# Create some handy rake tasks to move plugin migrations into db/migrations
# vendor/plugins/blogify/tasks/blogify_tasks.rake
namespace :blogify do
  desc "Sync extra files from blogify plugin."
  task :sync do
    system "rsync -ruv vendor/plugins/blogify/db/migrate db"
    system "rsync -ruv vendor/plugins/blogify/public ."
  end
end


# Railscast 150
# Rails Metal
# Added in 2.3. A way to go around the rails routing/dispatching... say to optimize a specific request
# Example: processList: frequent ajax updates
# Say in your view you have...
periodically_call_remote :url => "/processes/list", :update => "processes", :frequency => 3, :method => :get
# And an action such as...
def list
  render :text => `ps -axcr -o "pid,pcpu,pmemp,time,comm"`
end
# Create a 'metal' component to handle this instead.
# script/generate metal process_list
# app/metal/processes_list.rb
require(File.dirname(__FILE__) + "/../../config/environment") unlessdefined?(Rails)

class ProcessesList
  defself.call(env)
    if env["PATH_INFO"] =~ /^\/processes_list/
      [200, {"Content-Type" => "text/html"}, [`ps -axcr -o "pid,pcpu,pmem,time,comm"`]]
    else
      [404, {"Content-Type" => "text/html"}, ["Not Found"]]
    end
  end
end
# And now change your request...
periodically_call_remote :url => "/processes/list", :update => "processes", :frequency => 3, :method => :get
# Note: no logging for metal, doesn't hit rails.
# User ab to benchmark:
# script/server -e production -d
# ab -n 100 http://127.0.0.1:3000/processes/list
# ab -n 100 http://127.0.0.1:3000/processes_list


# Railscast 151
# Rack Middleware
# Usually for filtering req/res
# rake middleware to see all middleware for a Rails app
# config/environment.rb
config.middleware.use "ResponseTimer"
# lib/response_timer.rb
def initialize(app)
  @app = app
end
def call(env)
  [200, {'Content-Type' => 'text/html'}, 'Hello world!']
end
# That will make all requests return the above 200 response
# To integrate w/ other pieces of the stack, eg to add resonse time to body:
def call(env)
  status, headers, response = @app.call(env)
  [status, headers, "<!-- resp time -->" + response.body]
end
# Say you want to pass your middleware a parameter, or behave according to content-type:
# config.middleware.use "ResponseTimer", "Some Message"
def initialize(app, message = "Default Msg")
  @message = message
  @app = app
end
def call(env)
  status, headers, response = @app.call(env)
  if headers['Content-Type'].include? 'text/html'
    [status, headers, "<!-- #{@message} -->" + response.body]
  else
    [status, headers, response]
  end
end
# The above is fine, but the whole response.body thing is a rails-specific app. So what about other middleware apps?
# We need to work with response.each. Can get messy. So structure middleware like this:
# lib/response_timer.rb
class ResponseTimer
  def initialize(app, message = "Response Time")
    @app = app
    @message = message

  end

  # You should never modify instance variables in the call method (not threadsafe).
  def call(env)
    dup._call(env)
  end

  def _call(env)
    @start = Time.now
    @status, @headers, @response = @app.call(env)
    @stop = Time.now
    [@status, @headers, self]
  end

  def each(&block)
    block.call("<!-- #{@message}: #{@stop - @start} -->\n") if @headers["Content-Type"].include? "text/html"
    @response.each(&block)
  end
end
# Now that will work for non-rails-specific stuff.
# @headers['Content-Length'] should by updated to reflect the change in the response length. Otherwise Rack::Lint will complain.
# NOTE: see rack-contrib http://github.com/rack/rack-contrib/tree/master


# Railscast 152
# Rails 2.3 Extras
# AR Find in batches (avoiding retreiving thousands of records when doing mass changes)
Product.find_in_batches(:batch_size => 10) do |batch|
  puts "Products in batch: #{batch.size}"
end
Product.each(:batch_size => 10) do |product|
  puts product.name
end
# scoped_by Acts like named_scope, allows you to chain conditions!
Product.scoped_by_price(4.99).size
Product.scoped_by_price(4.99).first
Product.scoped_by_price(4.99).scoped_by_category_id(3).first
# Default scope
default_scope :order => "name"
# Try method (don't abuse this)
Product.find_by_price(4.99).name
Product.find_by_price(4.95).name
Product.find_by_price(4.95).try(:name)
Product.find_by_price(4.99).try(:name)
# Render partials w/ collections, concisely:
<!-- products/index.html.erb -->
<%= render @products %> # assumes partial product
<!-- products/show.html.erb -->
<%= render @product %>
# And even in the controller:
# categories_controller.rb
render 'new'# instead of :action => 'new'
render 'products/edit'# instead of :action => 'product'


# Railscast 153
# PDFs with Prawn
# PDF::Writer is ok, but Prawn may be better.
# Use prawnto as well for Rails work.
# views/orders/show.pdf.prawn
pdf.text "Order ##{@order.id}", :size => 30, :style => :boldpdf.move_down(30)
items = @order.cart.line_items.map do |item|
  [
    item.product.name,
    item.quantity,
    number_to_currency(item.unit_price),
    number_to_currency(item.full_price)
  ]
end
pdf.table items, :border_style => :grid,
  :row_colors => ["FFFFFF","DDDDDD"],
  :headers => ["Product", "Qty", "Unit Price", "Full Price"],
  :align => { 0 => :left, 1 => :right, 2 => :right, 3 => :right }
pdf.move_down(10)
pdf.text "Total Price: #{number_to_currency(@order.cart.total_price)}", :size => 16, :style => :bold

# orders_controller.rb
prawnto :prawn => { :top_margin => 75 }
def show
  @order = Order.find(params[:id])
end
# in url helpers, just specify the format
= link_to "Printable Invoice (PDF)", order_path(@order, :format => 'pdf')


# Railscast 154
# Polymorphic Association
# Some controller and view tips when using polymorphic associations and nested routes like:
map.resources :articles, :has_many => :comments
map.resources :photos, :has_many => :comments
map.resources :events, :has_many => :comments
# In controller of associated object, implement a find_commentable method
def find_commentable
  params.each do |name, value|
    if name =~ /(.+)_id$/
      return $1.classify.constantize.find(value)
    end
  end
  nil
end
# And to redirect after create, use a hack:
redirect_to :id => nil
# In the form helper:
form_for [@commentable, Comment.new] do |f|


# Railscast 155
# Beginning with Cucumber
# Think of cucumber as a high-level test suite (ala Rails integration tests) applied to the entire stack.
# script/generate cucumber sets up your Rails app for Cucumber use.
# Create feature file, eg manage_articles.feature
Feature: Manage Articles
  In order to make a blog
  As an author
  I want to create and manage articles

  Scenario: Articles List # Three basic parts: given, when, then
    Given I have articles titled Pizza, Breadsticks
    When I go to the list of articles
    Then I should see "Pizza"
    And I should see "Breadsticks"
# Run the scenario:
# cucumber features -n
# Results in undefined step. Create the step, eg step_definitions/article_steps.rb
Given /^I have articles titled (.+)$/ do |titles| # Regex submatch passed to block
  titles.split(', ').each do |title|
    Article.create!(:title => title)
  end
end
# Create a path to match scenario strings.


# Railscast 156
# Webrat
# You can use webrat for Rails integration tests.
# test/test_helper.rb
Webrat.configure do |config|
  config.mode = :rails  # :selenium (not sure if this actually works well or not)
end
# test/integration/authentication_test.rb
class AuthenticationTest < ActionController::IntegrationTest
  test "logging in with valid username and password" do
    User.create!(:username => "rbates", :email => "ryan@example.com", :password => "secret")
    visit login_url
    fill_in "Username", :with => "rbates"
    fill_in "Password", :with => "secret"
    click_button "Log in"
    assert_contain "Logged in successfully."
  end

  test "logging in with invalid username and password" do
    User.create!(:username => "rbates", :email => "ryan@example.com", :password => "secret")
    visit login_url
    fill_in "Username", :with => "rbates"
    fill_in "Password", :with => "badsecret"
    click_button "Log in"
    assert_contain "Invalid login or password."
  end
end


# Railscast 157
# RSpec Matchers & Macros
# Enhancing readiblity and reducing duplication.
# A "Matcher" is the thing that appears after should
article2.position.should == (article1.position + 1)
# to
article2.position.should be_one_more_than(article1.position)
# One approach: define the function
def be_one_more_than(number)
  simple_matcher("on more than #{number}") { |actual| actual == number + 1}
end
# But for reuse, create a matcher module like CustomMatchers.
# Be sure to require the custom matcher in spec_helper.rb, and config.include 'CustomMatchers'
# TM RSpec bundle has mat snippet, which generates a matcher template
module CustomMatchers
  class OneMoreThan
    def initialize(expected)
      @expected = expected
    end

    def matches?(actual)
      @actual = actual
      @actual == @expected+1
    end

    def failure_message_for_should
      "expected #{@actual.inspect} to be one more than #{@expected.inspect}"
    end

    def failure_message_for_should_not
      "expected #{@actual.inspect} not to be one more than #{@expected.inspect}"
    end
  end

  def be_one_more_than(expected)
    OneMoreThan.new(expected)
  end
end
# As for macros...
# Require them in the spec_helper, and config.include(ControllerMacros, :type => :controller)
module ControllerMacros
   def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def it_should_require_admin_for_actions(*actions)
      actions.each do |action|
        it "#{action} action should require admin" do
          get action, :id => 1
          response.should redirect_to(login_url)
          flash[:error].should == "Unauthorized Access"
        end
      end
    end
  end
  def login_as_admin
    user = User.new(:username => "admin", :email => "admin@example.com", :password => "secret")
    user.admin = true
    user.save!
    session[:user_id] = user.id
  end
end
# This allows you to...
it_should_require_admin_for_actions :new, :create, :edit, :update, :destroy


# Railscast 158
# Factories Not Fixtures
# See episode 60 "Testing without Fixtures" (Mocha)
# Data dependencies are tedious.
# Demonstration of Factory Girl. Mentions Machinist (very concise). ObjectDaddy.
Factory.define :user do |variable|
  f.username "foo"
  f.password "bar"
  f.password_confirmation { |u| u.password }
  f.email "foo@example.com"
  # Need uniqueness? use sequence
  f.sequence(:email) { |n| "foo#{n}@example.com" }
end
# In spec_helper.rb, require .../factories
user = Factory.create(:user, )
#or
user = Factory(:user) # shortcut
# Can set up some associations w/ FactoryGirl
Factory.define :article do |f|
  f.name "Foo"
  f.association :user
end
# Instead of persisting the obj to db, use Factory.build().
# Factory.attributes_for


# Railscast 159
# More on Cucumber
# An update on cucumber features (I didn't watch this. Noted here for reference.)


# Railscast 160
# Authlogic
# The canonical authlogic screencast. (Nothing new here for me.)


# Railscast 161
# Three Profiling Tools
# Demonstrates New Relic, FiveRuns TuneUp, and Rack::Bug
# Profile in production, not dev, but you can certainly run New Relic in dev.
# visit http://localhost/newrelic for page rendering time, sql query times, etc.
# TuneUP seems dead as of 2011. Anyway, it's a gem.
# Adds nifty toolbar to a running webapp view with a nice visualization of the rendering time,
# with a drill-down UI. Also can click on a stacktrace line which jumps to the line of code in TextMate.
# Rack::Bug is a plugin, provides a toolbar at the top of the webapp view. Install and create an initializer:
# middleware.rb
require "rack/bug"
ActionController::Dispatcher.middleware.use Rack::Bug,
  :ip_masks   => [IPAddr.new("127.0.0.1")],
  :secret_key => "epT5uCIchlsHCeR9dloOeAPG66PtHd9K8l0q9avitiaA/KUrY7DE52hD4yWY+8z1",
  :password   => "secret"
# localhost/__rack_bug__/bookmarklet.html gives you a little bookmarklet to toggle rack bug on and off.


# Railscast 162
# Tree-Based Navigation
# Uses a cms app as the context for creating a tree-based navigation element via acts_as_tree.
# Lets the page heirarchy drive the navigation (pages have parents and children).
f.collection_select :parent_id, Page.all(:order => "name"), :id, :name, :include_blank => true
# Not much new in this one.


# Railscast 163
# Self-Referential Association
# Consider Users with friend relationships (user M:N user).
# Encourages join model, eg Friendship to encapsulate the relationship.
# In order to display the inverse, eg "Who has friended me," use additional AR relationship declarations with the other key.
# user.rb
has_many :friendships
has_many :friends, :through => :friendships
has_many :inverse_friendships, :class_name => "Friendship", :foreign_key => "friend_id"
has_many :inverse_friends, :through => :inverse_friendships, :source => :user
# models/friendship.rb
belongs_to :user
belongs_to :friend, :class_name => "User"


# Railscast 164
# Cron in Ruby
# Sometimes scripting cron is a pain (syntax memorization, etc.)
# Encourages the "whenever" gem (https://github.com/javan/whenever)
# Creates a config/schedule.rb
every 2.hours do
  rake "thinking_sphinx:index"
end

every :reboot do
  rake "thinking_sphinx:start"
end

every :saturday, :at => "4:38am" do
  command "rm -rf #{RAILS_ROOT}/tmp/cache"
  runner "Cart.remove_abandoned"
end
# And to use this in your Capistrano deployment...
after "deploy:symlink", "deploy:update_crontab"

namespace :deploy do
  desc "Update the crontab file"
  task :update_crontab, :roles => :db do
    run "cd #{release_path} && whenever --update-crontab #{application}"
  end
end


# Railscast 165
# Edit Multiple
# References episode 52 (edit checkboxes)
# Demonstrates editing multiple objects using specialized controller actions.
# Detects attribute change when not blank (so radios need to be dropdowns, etc)
# Also demonstrates multiple attribute modification based on original values, such as when
# one might wish to discount all prices by 20%.
# product.rb
def price_modification
  price
end
def price_modification=(new_price)
  if new_price.to_s.ends_with? "%"
    self.price += (price * (new_price.to_f/100)).round(2)
  else
    self.price = new_price
  end
end


# Railscast 166
# Metric Fu
# Generates a bunch of reports from rcov and other tools.
# Place rakefile in lib/tasks/metric_fu.
rake metrics:all


# Railscast 167
# More on Virtual Attribtues
# See Railscast 16 "virtual attributes"
# Uses a tagging example with AR callbacks for model generation from attribute value.
# article.rb
class Article < ActiveRecord::Base
  has_many :comments, :dependent => :destroy
  has_many :taggings, :dependent => :destroy
  has_many :tags, :through => :taggings
  validates_presence_of :name, :content
  attr_writer :tag_names
  after_save :assign_tags

  def tag_names
    @tag_names || tags.map(&:name).join(' ')
  end

  private

  def assign_tags
    if @tag_names
      self.tags = @tag_names.split(/\s+/).map do |name|
        Tag.find_or_create_by_name(name)
      end
    end
  end
end
# _form.html
= f.label :tag_names
= f.text_field :tag_names


# Railscast 168
# Feed Parsing
# Suggests the feedzirra gem
# feed_entry.rb
class FeedEntry < ActiveRecord::Base
  def self.update_from_feed(feed_url)
    feed = Feedzirra::Feed.fetch_and_parse(feed_url)
    add_entries(feed.entries)
  end

  def self.update_from_feed_continuously(feed_url, delay_interval = 15.minutes)
    feed = Feedzirra::Feed.fetch_and_parse(feed_url)
    add_entries(feed.entries)
    loop do
      sleep delay_interval
      feed = Feedzirra::Feed.update(feed)
      add_entries(feed.new_entries) if feed.updated?
    end
  end

  private

  def self.add_entries(entries)
    entries.each do |entry|
      unless exists? :guid => entry.id
        create!(
          :name         => entry.title,
          :summary      => entry.summary,
          :url          => entry.url,
          :published_at => entry.published,
          :guid         => entry.id
        )
      end
    end
  end
end


# Railsast 169
# Dynamic Page Caching
# Generate static html files With basic caching...
# environment config:
config.action_controller.perform_caching = true
# controller:
caches_page :index
# Limited for dynamic pages (eg, when displaying current user name)
# So, we've got fragment caching, but fragments may be dynamic, say, based on user role.
# Proposes solution of using page caching, but extracting dynamic compents out of static page, and then load the dynamic components via JS. (!)
# I'm not so sure I like this solution, the comments generated some nice information and debate.
# Plus, perhaps some of this is alleviated with the :layout => false option on the caches_action macro.
#layouts/application.html.erb
= render 'layouts/dynamic_header' unless @hide_dynamic
# index.html.erb. Note the display:nones.
- javascript "jquery", "/users/current" # Bates' nifty helper
- @hide_dynamic = true
<div id="forums">
  <% for forum in @forums %>
    <div class="forum">
      <h2><%= link_to h(forum.name), forum %></h2>
      <p><%=h forum.description %></p>
      <p class="admin" style="display:none">
        <%= link_to "Edit", edit_forum_path(forum) %> |
        <%= link_to "Destroy", forum, :confirm => 'Are you sure?', :method => :delete %>
      </p>
    </div>
  <% end %>
</div>
<p class="admin" style="display:none"><%= link_to "New Forum", new_forum_path %></p>
# show.js.erb
$(document).ready(function() {
  $("#container").prepend('<%=escape_javascript render("layouts/dynamic_header") %>');
  <% if admin? %>
    $(".admin").show();
  <% end %>
});
# Also, check out Easy ESI: http://github.com/grosser/easy_esi


# Railscast 170
# OpenID with AuthLogic
# Refers to authlogic basics in episode 160.
# sudo gem install ruby-openid authlogic-oid
# Remember to rake the additional openID auth table migration: rake open_id_authentication:db:create
# Add openID identifier to user model.
# Change the usual controller object save logic to use a block, so authlogic can work its magic.
def create
  @user = User.new(params[:user])
  @user.save do |result|
    if result
      flash[:notice] = "Registration successful."
      redirect_to root_url
    else
      render :action => 'new'
    end
  end
end
# Just be aware that for update, use :attributes (since update_attributes doesn't use a block(?))
def update
  @user = current_user
  @user.attributes = params[:user]
  @user.save do |result|
    if result
      flash[:notice] = "Successfully updated profile."
      redirect_to root_url
    else
      render :action => 'edit'
    end
  end
end
# And for user attribute/openId mappings and the authlogic binding:
# models/user.rb
acts_as_authentic do |c|
  c.openid_required_fields = [:nickname, :email]
end

private

def map_openid_registration(registration)
  self.email = registration["email"] if email.blank?
  self.username = registration["nickname"] if username.blank?
end
# Demonstrates some UI massaging, esp with regard to validation messages, etc.


# Railscast 171
# Delayed Job
# Note that DJ was extracted from Shopify. (But use collectiveidea's version)
# http://github.com/collectiveidea/delayed_job
# Check out the recipes subdirectory in the repo.
# script/generate delayed_job (creates the delayed_jobs table)
# rake jobs:work
object.send_later(:method_name)
# Or create your own job classes (with perform method):
# lib/mailing_job.rb
class MailingJob < Struct.new(:mailing_id) # This is a nice little rubyism that saves a few lines of mundane code.
  def perform
    mailing = Mailing.find(mailing_id)
    mailing.deliver
  end
end
# And use it like so:
Delayed::Job.enqueue(MailingJob.new(params[:id]), -3, 3.days.from_now)


# Railscast 172
# Touch and caching (rails 2.3.3)
# Every model has a cache_key attribute generated from updated_at. This is how rails decides if a model has expired or not (cache hit or miss).
# However, adding associated models doesn't change the main model's updated_at, so the cache hasn't expired, and the new associated model wouldn't be loaded.
# So, use the :touch option with association declarations. This helps remove the need for sweepers.
# config/environments/development.rb
config.action_controller.perform_caching = true# (to try this in dev, since caching is off by default)
# comment.rb
belongs_to :article, :touch => true
# articles/show.html.erb
- cache @article do
  ...


# Railscast 173
# Screen Scraping with ScrAPI
# product.rb
def self.fetch_prices
  scraper = Scraper.define do
    process "div.firstRow div.priceAvail>div>div.PriceCompare>div.BodyS", :price => :text
    result :price
  end
  find_all_by_price(nil).each do |product|
    uri = URI.parse("http://www.walmart.com/search/search-ng.do?search_constraint=0&ic=48_0&search_query=" + CGI.escape(product.name) + "&Find.x=0&Find.y=0&Find=Find")
    product.update_attribute :price, scraper.scrape(uri)[/[.0-9]+/]
  end
end
# scrapitest.rb
require 'rubygems'
require 'scrapi'
scraper = Scraper.define do
  array :items
  process "div.item", :items => Scraper.define {
    process "a.prodLink", :title => :text, :link => "@href"
    process "div.priceAvail>div>div.PriceCompare>div.BodyS", :price => :text
    result :price, :title, :link
  }
  result :items
end
uri = URI.parse("http://www.walmart.com/search/search-ng.do?search_constraint=0&ic=48_0&search_query=lost+third+season&Find.x=0&Find.y=0&Find=Find")
scraper.scrape(uri).each do |product|
  puts product.title
  puts product.price
  puts product.link
  puts
end


# Railscast 174
# Ajax Pagination
# Still uses will_paginate, but with jQuery to add behavior.
# Illustrates the use of the jQuery live() method.
# Illustrates the usefulness via the ajax-rendered pagination links that need the onClick behavior.
# Note that xhr requests should include the Accept javascript header in order for Rails to render the .js.erb view.
# products/index.js.erb
$("#products").html("<%= escape_javascript(render("products")) %>");
# public/javascripts/pagination.js
$(function() {
  $(".pagination a").live("click", function() {
    $(".pagination").html("Page is loading...");
    $.getScript(this.href);
    return false;
  });
});
// For older jQuery versions...
// jQuery.ajaxSetup({
//   'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
// });


# Railscast 175
# AJAX History and Bookmarks
# One approach is to append an anchor to the URL.
# Uses the jQuery URL Utils Plugin
# -- now deprecated. See jQuery BBQ plugin and the jQuery urlInternal plugins.
# Throw jquery.ba-url.js in the /javascripts junk drawer.
# pagination.js
$(function() {
  $(".pagination a").live("click", function() {
    $.setFragment({ "page" : $.queryString(this.href).page }) // Provided by jQuery URL Utils plugin
    $(".pagination").html("Page is loading...");
    return false;
  });

  $.fragmentChange(true);   // Provided by jQuery URL Utils plugin
  $(document).bind("fragmentChange.page", function() {
    $.getScript($.queryString(document.location.href, { "page" : $.fragment().page }));
  });

  if ($.fragment().page) { // Make sure when we reload a page or visit it the first time, it sends the AJAX request for the particular page fragment.
    $(document).trigger("fragmentChange.page");
  }
});


# Railscast 176
# Searchlogic
# Code smell: programmatic query conditions
# Searchlogic pretty much generates a ton of nice named_scopes efficiently via method_missing.
# Tip: Don't forget that _ in irb returns the return value of the last command (handy when you forget to assign the value of an expression to a variable)
# Some examples:
Product.name_like("Video")
Product.name_not_like("Video").price_gt(5).price_lt(200)
Product.name_like_any(["couch", "table"])
Product.name_like_all(["video", "console"])
Product.category_name_like("elect")
Product.search(:category_name_like => "elect", :price_lt => "100") # Generates a 'search' object applying the particular hash options
s.all
s.name_like("video")
Product.ascend_by_name
#products_controller.rb
@products = Product.name_like_all(params[:search].to_s.split).ascend_by_name
# or
@search = Product.search(params[:search])
@products = @search.all
# index.html
index.html.erb
<% form_for @search do |f| %>
  <p>
    <%= f.label :name_like, "Name" %><br />
    <%= f.text_field :name_like %>
  </p>
  <p>
    <%= f.label :category_id_equals, "Category" %><br />
    <%= f.collection_select :category_id_equals, Category.all, :id, :name, :include_blank => true %>
  </p>
  <p>
    <%= f.label :price_gte, "Price Range" %><br />
    <%= f.text_field :price_gte, :size => 8 %> - <%= f.text_field :price_lte, :size => 8 %>
  </p>
  <p>
    <%= f.submit "Submit" %>
  </p>
<% end %>
<p>
  Sort by:
  <%= order @search, :by => :name %> |
  <%= order @search, :by => :price %>
</p>
# Also provides a nice order helper to allow user to choose the sort criteria of search results


# Railscast 177
# Model Versioning
# Suggests trying Vestal Versions, has some nice time-related features.
# Create the versions table...
script/generate vestal_versions_migration
script/generate migration version_existing_pages
# Call the macro in your AR model
# models/page.rb
class Page < ActiveRecord::Base
  versioned
end
# run the version_existing_pages migration
say_with_time "Setting initial version for pages" do
  Page.find_each(&:touch)
end
# View...
<p>
  <%= link_to "Edit", edit_page_path(@page) %>
  | Version <%= @page.version %>
  <% if @page.version > 1 %>
    | <%= link_to "Previous version", :version => @page.version-1 %>
  <% end %>
  <% if params[:version] %>
    | <%= link_to "Latest version", :version => nil %>
  <% end %>
</p>
#pages_controller.rb
def show
  @page = Page.find(params[:id])
  @page.revert_to(params[:version].to_i) if params[:version]
end
# Other cool features...
p = Page.all
p.versions # Array of all versions
p.revert_to(7.minutes.ago) # Reverts to the version that was current at that time
p.content
p.revert_to(:last) # Some handy symbols you can pass


# Railscast 178
# Seven Security Tips
# 1) Mass assignment
# Symptom: update_attributes(param[:project])
# Use attr_accessible
# 2) File uploads
# Symptom: unchecked file types could, for example, a .php file that gets executed on the server when requested
# Check content type, file extension, apache config (turn off script execution)
# 3) Filter log params
# filter_paramter_logging :password
# 4) CSRF protection
# make sure protect_from_forgery is called in ApplicationController.
# 5) Authorizing Ownership
# Symptom: users might manipulate id in url, accessing model data that isn't "theirs"
# Simplest solution: always used model-scoped finders, eg. current_user.projects (not Project.find())
# 6) SQL Injection
# Don't interpolate strings, use AR's ? syntax for condition.
# 7) HTML Injection (XSS)
# Symptom: rendering data that is user-generated/accessible
# Be sure to h() (or use sanitize() to whitelist some tags). (Now the default behavior in Rails 3)


# Railscast 179
# Seed Data
# Not much new here.
# To use fixture data as seed data:
require 'active_record/fixtures'
Fixtures.create_fixtures("#{Rails.root}/test/fixtures", "operating_systems")


# Railscast 180
# Finding unused CSS
# CSS Cruft? Try Dust-Me Selectors (FF plugin)
# Try the deadweight gem, a css coverage tool, via command line or rake task.
# https://github.com/aanand/deadweight


# Railscast 181
# Include vs Joins
# Given a user, comment, membership and group model...
# models/comment.rb
class Comment < ActiveRecord::Base
  belongs_to :user
end
# models/user.rb
class User < ActiveRecord::Base
  has_many :memberships
  has_many :groups, :through => :memberships
  has_many :comments
end
# models/membership.rb
class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
end
# models/group.rb
class Group < ActiveRecord::Base
  has_many :memberships
  has_many :users, :through => :memberships
  def comments
    Comment.scoped(:joins => {:user => :memberships}, :conditions => { :memberships => { :group_id => id } })
  end
end
# Bottom line, use :include when you want to work with the associated model attributes (and don't when you don't).
# Use :join when you want to specify find conditions that are depenedent on associated table attributes.
# Examples
c = Comment.all(:joins => :user, :conditions => { :users => { :admin => true } })
c.first.users # Generates another query
c = Comment.all(:include => :user, :conditions => { :users => { :admin => true } })
c.first.users # No additional query
User.all(:joins => :comments, :select => "users.*, count(comments.id) as comments_count", :group => "users.id")
# The above finder allows us to load the comment count as an attirbute rather than executing a query for each user.comments.count.
g = Group.first
Comment.all(:joins => {:user => :memberships}, :conditions => { :memberships => { :group_id => g.id } })
# Which can be refactored to...
# group.rb
def comments
  Comment.scoped(:joins => {:user => :memberships}, :conditions => { :memberships => { :group_id => id } })
end
# The benefit being that you can chain the call of g.comments



#NEXT (a bookmark for Yong)


# Railscast 188
# Declarative authorization with declarative_authorization
# config/authorization_rules.rb
# http://media.railscasts.com/videos/188_declarative_authorization.mov
# config/environment.rb
config.gem "declarative_authorization", :source => "http://gemcutter.org"
# config/authorization_rules.rb
authorization do
  role :admin do
    has_permission_on [:articles, :comments], :to => [:index, :show, :new, :create, :edit, :update, :destroy]
  end
  role :guest do
    has_permission_on :articles, :to => [:index, :show]
    has_permission_on :comments, :to => [:new, :create]
    has_permission_on :comments, :to => [:edit, :update] do
      if_attribute :user => is { user }
    end
  end
  role :moderator do
    includes :guest
    has_permission_on :comments, :to => [:edit, :update]
  end
  role :author do
    includes :guest
    has_permission_on :articles, :to => [:new, :create]
    has_permission_on :articles, :to => [:edit, :update] do
      if_attribute :user => is { user }
    end
  end
end
# application_controller.rb
before_filter { |c| Authorization.current_user = c.current_user }
protected
def permission_denied
  flash[:error] = "Sorry, you are not allowed to access that page."
  redirect_to root_url
end
# articles_controller.rb
filter_resource_access
# articles/show.html.erb
<% if permitted_to? :edit, @article %>
  <%= link_to "Edit", edit_article_path(@article) %> |
<% end %>
<% if permitted_to? :destroy, @article %>
  <%= link_to "Destroy", @article, :method => :delete, :confirm => "Are you sure?" %> |
<% end %>


# Railscast 209 Devise
rails g devise:install
rails g devise User
# Gives you the model, migration, routes and view files for the automagic that is Devise.
# Use rake:routes to see the routes to register, log in, etc.


# Railscast 210 Customizing Devise
rails g devise:views -e haml
# See config/initializers/devise.rb
# See config/locales/devise.en.yml


# Railscast 233
# Janrain Engage with Devise
# Janrain offers a consolidated
# See rpx_now, authlogic_rpx, devise_rpx_connectable
# You can embed the rpx form in an iframe on your site for more visual integration.
# See the railscast starting at about 1/2 way through.



# Railscast 235 OmniAuth Part I
# Basically a suite of middleware that allows you to authenticate against remote services like twitter.
# Works with Devise.
# See github.com/intridea/auth_buttons


# Railscast 236 OmniAuth Part II
# Demonstrates OmniAuth integration with Devise.
# Easy to add services, but lots of self-written bootstrapping seems necessary. Long cast.


# Railscast 241 Simple OmniAuth
# Demonstrates using OmniAuth on its own, which relies on 3rd party auth services like twitter.



# Railscast 265 Rails 3.1 Overview
# Uses jQuery by default, but there's a -j option for `rails new`
# Has asset template engines sass and coffee-script on by default.
# Has app/assets for js and stylesheets (rather than public).
# Uses Sprockets to generate amalgamation of js.
# ActiveRecord
# Migrations have change method rather than up/down
# Ryan mentions AR identity maps but it doesn't seem like this will be a part of 3.1
# Has nestable has_many :through associations
# Has role options for attribute_accessible, and :as option for AR dml function calls.
# Multipart form declaration is unnecessary.
# Can pass subdomain option to url helpers.
# Uses the turn gem to beautify test output
# Gist of changelog: https://gist.github.com/958283
