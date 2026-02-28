import React, {Component} from 'react';

function validateEmail(text) {
  const re = new RegExp('^[a-zA-Z0-9-_+\.;]+@([a-zA-Z0-9-_]\.)+([a-zA-Z0-9]+)$');
  return text.match(re);
}

class DecoratedEmail extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    const valid = validateEmail(this.props.text);

    return (
        <div className={`decorated-email ${valid ? 'valid-email' : 'invalid-email'}`}>
          {this.props.text}
        </div>
    );
  }
}

class DecoratedEmailInput extends React.Component {
  constructor(props) {
    super(props);
    this.state = {emails: []};
  }

  addEmail(email) {
    this.setState({emails: [ ...this.state.emails, email ]});
  }

  handleChange = (e) => {
    const re = new RegExp('[ ,;\t]');
    const chars = e.target.value.split('');
    const last = chars[chars.length - 1];
    if (last.match(re)) {
      const email = chars.join('');
      this.addEmail(email);
    }
  }

  render() {
    console.log("emails are: " + this.state.emails);
    return (
        <input id="email" placeholder="One or more emails..."
               onChange={(e) => this.handleChange(e)}/>
    )
  }
}

class App extends Component {
  render() {
    return (
        <div>
          <DecoratedEmailInput/>
        </div>
    );
  }
}

export default App;

