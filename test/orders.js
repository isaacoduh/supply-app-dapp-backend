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

  describe('Pay', () => {
    const orderId = '200';
    const totalPrice = web3.utils.toWei('2.5', 'ether');

    const date = new Date();
    date.setMonth(date.getMonth() + 1);
    const deliveryDate = Math.round(date.getTime() / 1000);

    it('3. Should not be paid as there is no order', () => {
      return Orders.deployed().then((instance) => {
        return instance.pay(orderId, {value:200});
      }).then(assert.fail).catch((error => {
        assert(error.message.indexOf("Order is not found") >= 0);
      }));
    });

    it('4. Should not be paid as the order price does not match the value of the transaction', () => {
      return Orders.deployed().then(async (instance) => {
        await instance.add(orderId, totalPrice, deliveryDate, {from: accounts[0]});
        return instance.pay(orderId, {value: 200});
      }).then(assert.fail).catch((error) => {
        assert(error.message.indexOf("The order price does not match the value of the transaction") >= 0);
      });
    });

    it('5. Should be paid', () => {
      return Orders.deployed().then((instance) => {
        return instance.pay(orderId, {value: totalPrice, from: accounts[1]});
      }).then((tx) => {
        assert.equal(tx.logs[0].event, 'OrderPaid', "Event name does not match OrderPaid");
      });
    });

    it('6. Should not be paid again as the other has been paid', () => {
      return Orders.deployed().then((instance) => {
        return instance.pay(orderId, {value: totalPrice, from: accounts[1]});
      }).then(assert.fail).catch((error) => {
        assert(error.message.indexOf('The order has been paid') >= 0);
      });
    });

  });
});