import getContInst    from './getContInst'
import getTicketPrice from './getTicketPrice'
import utils          from '../components/utils'
import satCont        from './etheraffleSatContract'

/* Sorts entry numbers then enters raffle. Returns txHash or rejects with error */
export default (_which, _user, _eNums) => {
  return new Promise((resolve, reject) => {
    //if(window.web3 === null || window.web3.isConnected() === false)
      //return reject(new Error("Failed to buyTicket - no web3 connection!"))
    let cont, price
    getTicketPrice(_which)
    .then(res => {
      price = res
      if(_which === "Saturday") cont = satCont
      getContInst(_which)
      .then(etheraffle => {
        let eNums = utils.sortEnums(_eNums),
            data  = etheraffle.enterRaffle.getData(eNums, 0)
        window.web3.eth.sendTransaction({
          value: price,
          data:  data,
          from:  _user,
          to:    cont.cAdd,
          gas:   cont.gasForEntry
        },(err, txHash) => {
          return !err ? resolve(txHash) : reject(err)
        })
      })
    }).catch(err => {
      return reject(err)
    })
  })
}
