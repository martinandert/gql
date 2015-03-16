var App = React.createClass({
  getInitialState: function() {
    return {
      query: initialQuery,
      result: ''
    };
  },

  componentDidMount: function() {
    $(window).resize(this.adjustControlHeights).trigger('resize');
  },

  render: function() {
    var options = queries.map(function(query, i) {
      return <option key={i} value={query.value}>{query.name}</option>;
    });

    return (
      <form onSubmit={this.handleSubmit}>
        <h1>GQL Demo</h1>

        <div className="controls">
          <select id="query-selector" ref="selector" onChange={this.handleQuerySelected}>
            <option value="">[ Select Query ]</option>
            {options}
          </select>

          <textarea value={this.state.query} onChange={this.handleQueryChanged} />
          <button type="submit" className="execute">Execute Query</button>
          <pre><code>{this.state.result}</code></pre>
          <p className="reset-note">All data will be reset daily at 08:00 UTC.</p>
        </div>
      </form>
    );
  },

  handleSubmit: function(e) {
    var self = this;

    $.post('/query', { q: this.state.query }, function(data) {
      self.setState({ result: data });
    }, 'text');

    e.preventDefault();
  },

  handleQueryChanged: function(e) {
    this.setState({ query: e.target.value });
  },

  handleQuerySelected: function(e) {
    if (e.target.value.length) {
      this.setState({ query: e.target.value });
    }
  }
});

React.render(<App />, document.getElementById('root'));
