# encoding: utf-8
require 'test_helper'

class ModelTest < ActiveSupport::TestCase
  test 'references test' do

    # create base
    groups = Group.where( name: 'Users' )
    roles  = Role.where( name: %w(Agent Admin) )
    agent1 = User.create_or_update(
      login: 'model-agent1@example.com',
      firstname: 'Model',
      lastname: 'Agent1',
      email: 'model-agent1@example.com',
      password: 'agentpw',
      active: true,
      roles: roles,
      groups: groups,
      updated_at: '2015-02-05 16:37:00',
      updated_by_id: 1,
      created_by_id: 1,
    )
    agent2 = User.create_or_update(
      login: 'model-agent2@example.com',
      firstname: 'Model',
      lastname: 'Agent2',
      email: 'model-agent2@example.com',
      password: 'agentpw',
      active: true,
      roles: roles,
      groups: groups,
      updated_at: '2015-02-05 17:37:00',
      updated_by_id: agent1.id,
      created_by_id: 1,
    )
    organization1 = Organization.create_if_not_exists(
      name: 'Model Org 1',
      updated_at: '2015-02-05 16:37:00',
      updated_by_id: 1,
      created_by_id: 1,
    )
    organization2 = Organization.create_if_not_exists(
      name: 'Model Org 2',
      updated_at: '2015-02-05 16:37:00',
      updated_by_id: agent1.id,
      created_by_id: 1,
    )
    roles     = Role.where( name: 'Customer' )
    customer1 = User.create_or_update(
      login: 'model-customer1@example.com',
      firstname: 'Model',
      lastname: 'Customer1',
      email: 'model-customer1@example.com',
      password: 'customerpw',
      active: true,
      organization_id: organization1.id,
      roles: roles,
      updated_at: '2015-02-05 16:37:00',
      updated_by_id: 1,
      created_by_id: 1,
    )
    customer2 = User.create_or_update(
      login: 'model-customer2@example.com',
      firstname: 'Model',
      lastname: 'Customer2',
      email: 'model-customer2@example.com',
      password: 'customerpw',
      active: true,
      organization_id: nil,
      roles: roles,
      updated_at: '2015-02-05 16:37:00',
      updated_by_id: agent1.id,
      created_by_id: 1,
    )
    customer3 = User.create_or_update(
      login: 'model-customer3@example.com',
      firstname: 'Model',
      lastname: 'Customer3',
      email: 'model-customer3@example.com',
      password: 'customerpw',
      active: true,
      organization_id: nil,
      roles: roles,
      updated_at: '2015-02-05 16:37:00',
      updated_by_id: agent1.id,
      created_by_id: agent1.id,
    )

    # user

    # verify agent1
    references1 = Models.references('User', agent1.id)

    assert_equal(references1['User']['updated_by_id'], 3)
    assert_equal(references1['User']['created_by_id'], 1)
    assert_equal(references1['Organization']['updated_by_id'], 1)
    assert(!references1['Group'])

    references_total1 = Models.references_total('User', agent1.id)
    assert_equal(references_total1, 7)

    # verify agent2
    references2 = Models.references('User', agent2.id)

    assert(!references2['User'])
    assert(!references2['Organization'])
    assert(!references2['Group'])
    assert(references2.empty?)

    references_total2 = Models.references_total('User', agent2.id)
    assert_equal(references_total2, 0)

    Models.merge('User', agent2.id, agent1.id)

    # verify agent1
    references1 = Models.references('User', agent1.id)

    assert(!references1['User'])
    assert(!references1['Organization'])
    assert(!references1['Group'])
    assert(references1.empty?)

    references_total1 = Models.references_total('User', agent1.id)
    assert_equal(references_total1, 0)

    # verify agent2
    references2 = Models.references('User', agent2.id)

    assert_equal(references2['User']['updated_by_id'], 3)
    assert_equal(references2['User']['created_by_id'], 1)
    assert_equal(references2['Organization']['updated_by_id'], 1)
    assert(!references2['Group'])

    references_total2 = Models.references_total('User', agent2.id)
    assert_equal(references_total2, 7)

    # org

    # verify agent1
    references1 = Models.references('Organization', organization1.id)

    assert_equal(references1['User']['organization_id'], 1)
    assert(!references1['Organization'])
    assert(!references1['Group'])

    references_total1 = Models.references_total('Organization', organization1.id)
    assert_equal(references_total1, 1)

    # verify agent2
    references2 = Models.references('Organization', organization2.id)

    assert(references2.empty?)

    references_total2 = Models.references_total('Organization', organization2.id)
    assert_equal(references_total2, 0)

    Models.merge('Organization', organization2.id, organization1.id)

    # verify agent1
    references1 = Models.references('Organization', organization1.id)

    assert(references1.empty?)

    references_total1 = Models.references_total('Organization', organization1.id)
    assert_equal(references_total1, 0)

    # verify agent2
    references2 = Models.references('Organization', organization2.id)

    assert_equal(references2['User']['organization_id'], 1)
    assert(!references2['Organization'])
    assert(!references2['Group'])

    references_total2 = Models.references_total('Organization', organization2.id)
    assert_equal(references_total2, 1)

  end

end