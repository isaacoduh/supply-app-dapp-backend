const Orders = artifacts.require("Orders");

contract('Orders', (accounts) => {
  describe('Add', () => {
    const orderId = '100';
    const totalPrice = web3.utils.toWei('2.5', 'ether');

    const date = new Date();
    date.setMonth(date.getMonth() + 1);
    const deliveryDate = Math.round(date.getTime() / 1000);

    it('1. The order should not be added as the sender is not authorized', () => {
      return Orders.deployed().then((instance) => {
        return instance.add(orderId, totalPrice, deliveryDate, {
          from: accounts[1]
        });
      }).then(assert.fail).catch((error) => {
        assert(error.message.indexOf("The sender is not authorized to perform transaction") >= 0);
      });
    });

    it('2. The order should be added', async () => {
      const instance = await Orders.deployed();
      await instance.add(orderId, totalPrice, deliveryDate);
      let order = await instance.get(orderId);
      assert.equal(order.status, 0, "Order status doesn't match created");
    });
  });
});