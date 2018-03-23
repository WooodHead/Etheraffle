import React from 'react'
import FAQ from '../faq/faq'
import Results from '../results/results'
import Wednesdayraffle from '../wednesdayraffle/wednesdayraffle'

export default class Wednesday extends React.Component{

  constructor(props) {
    super(props)
    this.state = {
      screenIndex: 3,
      mounted: false,
      subScreenIndex: 2
    }
  }

  componentWillMount() {
    this.setState({mounted: true})
    this.props.eventEmitter.emit("navigateScreen", {screenIndex: 3})
  }

  handleClick(index) {
    if (this.state.mounted) this.setState({subScreenIndex: index})
  }

  componentWillUnmount()  {
    if (this.state.mounted) this.setState({mounted: false})
  }

  render() {
    return(
      <div className="screen">
        <div className="subNav">

          <div
            className ={this.state.subScreenIndex === 1 ? "subNav-item results active-subNav" : "subNav-item results"}
            onClick={(index) => this.handleClick(1)}
            style={this.state.subScreenIndex === 1 ? {color: 'rgba(62,214,126,1)'} : {color: 'lightgrey'}}>
            <h3 className="subScreen1">Results</h3>
          </div>

          <div className ="subNav-item spacerOne"></div>

          <div
            className ={this.state.subScreenIndex === 2 ? "subNav-item play active-subNav" : "subNav-item play"}
            onClick={(index) => this.handleClick(2)}
            style={this.state.subScreenIndex === 2 ? {color: 'rgba(236,60,226,1)'} : {color: 'lightgrey'}}>
            <h3 className="subScreen2">Play!</h3>
          </div>

          <div className ="subNav-item spacerTwo"></div>

          <div
            className ={this.state.subScreenIndex === 3 ? "subNav-item help active-subNav" : "subNav-item help"}
            onClick={(index) => this.handleClick(3)}
            style={this.state.subScreenIndex === 3 ? {color: 'rgba(51,211,224,1)'} : {color: 'lightgrey'}}>
            <h3 className="subScreen3">FAQ</h3>
          </div>
        </div>

        <div className="subcontent">
          {this.state.subScreenIndex === 1 &&
            <Results
              screenIndex={this.state.screenIndex}
              subScreenIndex={this.state.subScreenIndex} />
          }

          {this.state.subScreenIndex === 2 &&
            <Wednesdayraffle
              screenIndex={this.state.screenIndex}
              subScreenIndex={this.state.subScreenIndex} />
          }

          {this.state.subScreenIndex === 3 &&
            <FAQ
              screenIndex={this.state.screenIndex}
              subScreenIndex={this.state.subScreenIndex} />
          }
        </div>
      </div>
    )
  }
}
