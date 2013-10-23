Given(/^I have a sample configuration with native metrics$/) do
  reading_group = FactoryGirl.create(:reading_group, id: nil)
  @configuration = FactoryGirl.create(:configuration, id: nil)
  metric_configuration = FactoryGirl.create(:metric_configuration,
                                            {id: nil,
                                             reading_group_id: reading_group.id,
                                             configuration_id: @configuration.id})
end

Given(/^I have a sample repository within the sample project$/) do
  @repository = FactoryGirl.create(:repository, {project_id: @project.id, configuration_id: @configuration.id, id: nil})
end

Given(/^I start to process that repository$/) do
  @repository.process
end

Given(/^I wait up for a ready processing$/) do
  unless Processing.has_ready_processing(@repository.id)
    while(true)
      if Processing.has_ready_processing(@repository.id)
        break
      else
        sleep(10)
      end
    end
  end
end

Given(/^I am at the New Repository page$/) do
  visit new_project_repository_path(@project.id)
end

When(/^I set the select field (.+) as "(.+)"$/) do |field, text|
  find('option', text: text).click()
end

When(/^I set the select field Configuration as the sample configuration$/) do
  find('option', text: @configuration.name).click()
end

When(/^I visit the repository show page$/) do
  visit project_repository_path(@project.id, @repository.id)
end

Then(/^I should see the sample repository name$/) do
  page.should have_content(@repository.name)
end