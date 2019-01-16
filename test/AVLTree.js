const { TestHelper } = require('zos')
const { encodeCall } = require('zos-lib')
const chai = require('chai')
const chaiBn = require('chai-bignumber')

chai.use(chaiBn());
chai.should()

const AVLTree = artifacts.require('AVLTree')

contract('AVLTree', function ([_, owner]) {

  beforeEach(async function () {
    this.avl = await AVLTree.new()
  })

  it('should create a proxy for the EVM package', async function () {
    await this.avl.initialize()
  })


  it('should successfully a insert [20, 4, 15]', async function () {
    await this.avl.initialize()

    await this.avl.insert(20)
    const id20 = await this.avl.getLastId()
    const insert20 = await this.avl.getNodeById(id20)
    id20.should.be.bignumber.eq(1)

    await this.avl.insert(4)
    const id4 = await this.avl.getLastId()
    const insert4 = await this.avl.getNodeById(id4)
    id4.should.be.bignumber.eq(2)

    await this.avl.insert(15)
    const id15 = await this.avl.getLastId()
    const insert15 = await this.avl.getNodeById(id15)
    id15.should.be.bignumber.eq(3)

    console.log(insert20)
    console.log(insert4)
    console.log(insert15)

  })
})
