# frozen_string_literal: true

require 'selenium-webdriver'

class Electricity
  KEYS = Selenium::WebDriver::Keys::KEYS

  attr_accessor :driver, :wait

  def initialize(**options)
    @driver = options[:driver] || Selenium::WebDriver.for(:chrome)
    driver.manage.timeouts.implicit_wait = options[:timeout] || 10
    @wait = Selenium::WebDriver::Wait.new(timeout: options[:timeout] || 10)
  end

  def login(url, id, password)
    driver.navigate.to(url)
    wait_for { driver.find_element(:id, 'loginForm') }.tap do |form|
      form.find_element(:id, 'loginId').send_keys(id)
      form.find_element(:id, 'passWord').send_keys(password)
    end.submit
  end

  def records(after: nil, before: nil)
    navigate_to_records
    specify_date_until(before) if before
    data = parse_records
    data.keys.include?(after) || after.nil? ? data : data.merge(records(after: after, before: data.keys.sort.first))
  end

  def quit
    driver.quit
  end

  private

  # needed to wait for animation
  def wait_for
    subject = nil
    wait.until { (subject = yield).displayed? }
    sleep(1.2) # FIXME: wait animations to complete
    subject
  end

  def navigate_to_records
    return if driver.current_url.include?('ReferenceCrrspndDetailsPrtlServlet')
    wait_for { driver.find_element(:xpath, '//a[@href="SelectDetailsBillPPrtlServlet"]') }.click
    wait_for { driver.find_element(:id, 'submitReferenceCrrspndDetailsPrtl') }.click
  end

  def specify_date_until(date)
    input = wait_for { driver.find_element(:id, 'EntryInputForm_entryModel_svcStrtDt') }
    current_date = input.attribute('value')
    input.clear
    input.send_keys(date + KEYS[:tab])
    wait.until { driver.execute_script('return barChart.datasets[0]["bars"].slice(-1)[0]["label"]') != current_date rescue nil }
  end

  def parse_records
    wait_for { driver.find_element(:id, 'EntryInputForm_entryModel_svcStrtDt') }
    driver.execute_script('return barChart.datasets[0]["bars"]').map do |bar|
      [bar['label'], bar['value'].to_f.nonzero?]
    end.to_h
  end
end
