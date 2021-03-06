import React from 'react'
import mist from '../../images/mist_logo.jpg'
import cipher from '../../images/cipher_logo.png'
import metamask from '../../images/metamask_logo.jpg'

const Mobile = props => (
  <div className='info'>
    <img className='cipherLogo' src={cipher} alt='Cipher Browser Logo' />
      <p className='justify'>
        <span className={"styledSpan screen" + props.sI}>
          On mobile?&nbsp;
        </span>
        <a className={"screen" + props.sI} target="_blank" rel="noopener noreferrer" href="https://www.cipherbrowser.com/">
          Cipher Browser is the world's first full-featured mobile dapp browser and wallet for the Ethereum blockchain. Click for more info.
        </a>
      </p>
  </div>
)

const Desktop = props => (
  <React.Fragment>
    <div className='info'>
      <img className='metamaskLogo' src={metamask} alt='Metamask Logo' />
        <p className='justify'>
          <span className={"styledSpan screen" + props.sI}>
            This is one to get you started!&nbsp;
          </span>
          <a className={"screen" + props.sI} target="_blank" rel="noopener noreferrer" href="https://metamask.io/">
            MetaMask is a bridge that allows you to visit the web of tomorrow in your browser today. It allows you to run ethereum ÐApps directly in your Chrome browser. Click for more info.
          </a>
        </p>
    </div>
    <div className='info'>
      <img className='mistLogo' src={mist} alt='Mist Browser Logo' />
        <p className='justify'>
          <span className={"styledSpan screen" + props.sI}>
            Want to try the browser of the future?&nbsp;
          </span>
          <a className={"screen" + props.sI} target="_blank" rel="noopener noreferrer" href="https://github.com/ethereum/mist/releases" >
            The Mist Browser is a web-browser and ethereum wallet hybrid. It is specifically tailored for non-technical users and so a top choice for browsing and using ÐApps. Click for more info.
          </a>
        </p>
    </div>
  </React.Fragment>
)

export default props => (
  <div className={"modalNotConnectedInfo screen" + props.sI}>
    <p className='noCxn'>
      <span className={"styledSpan screen" + props.sI}>No ethereum connection detected!</span>
      <br/>
      Below are some options for getting connected to the ethereum network.
    </p>
    {window.innerWidth > 800 ? <Desktop sI={props.sreenIndex} /> : <Mobile sI={props.sreenIndex} />}
  </div>
)
