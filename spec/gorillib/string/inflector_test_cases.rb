# encoding: utf-8

module InflectorTestCases

  CamelToUnderscore = {
    "Product"               => "product",
    "SpecialGuest"          => "special_guest",
    "ApplicationController" => "application_controller",
    "Area51Controller"      => "area51_controller"
  }

  UnderscoreToLowerCamel = {
    "product"                => "product",
    "special_guest"          => "specialGuest",
    "application_controller" => "applicationController",
    "area51_controller"      => "area51Controller"
  }

  CamelToUnderscoreWithoutReverse = {
    "HTMLTidy"              => "html_tidy",
    "HTMLTidyGenerator"     => "html_tidy_generator",
    "FreeBSD"               => "free_bsd",
    "HTML"                  => "html",
  }

  CamelWithModuleToUnderscoreWithSlash = {
    "Admin::Product" => "admin/product",
    "Users::Commission::Department" => "users/commission/department",
    "UsersSection::CommissionDepartment" => "users_section/commission_department",
  }

  UnderscoreToHuman = {
    "employee_salary" => "Employee salary",
    "employee_id"     => "Employee",
    "underground"     => "Underground"
  }

  MixtureToTitleCase = {
    'active_record'       => 'Active Record',
    'ActiveRecord'        => 'Active Record',
    'action web service'  => 'Action Web Service',
    'Action Web Service'  => 'Action Web Service',
    'Action web service'  => 'Action Web Service',
    'actionwebservice'    => 'Actionwebservice',
    'Actionwebservice'    => 'Actionwebservice',
    "david's code"        => "David's Code",
    "David's code"        => "David's Code",
    "david's Code"        => "David's Code"
  }
end
