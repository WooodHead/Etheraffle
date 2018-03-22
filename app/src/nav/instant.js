import React from 'react'
import Subnav from '../nav/subnav'

export default class Instant extends React.Component {

  constructor(props) {
    super(props)
    this.state = {
      screenIndex: 1,
      subScreenIndex: 2
    }
  }

  componentWillMount() {
    this.props.eventEmitter.emit("navigateScreen", {screenIndex: 1})
  }

  render() {
    return(
      <Subnav
        screenIndex={this.state.screenIndex}
        subScreenIndex={this.state.subScreenIndex} />
      )
    }
  }