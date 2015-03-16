define('ace/mode/graphql', function(require, exports, module) {
  var oop = require("ace/lib/oop");
  var TextMode = require("ace/mode/text").Mode;
  var Tokenizer = require("ace/tokenizer").Tokenizer;
  var GraphQLHighlightRules = require("ace/mode/graphql_highlight_rules").GraphQLHighlightRules;
  var MatchingBraceOutdent = require("ace/mode/matching_brace_outdent").MatchingBraceOutdent;
  var CstyleBehaviour = require("ace/mode/behaviour/cstyle").CstyleBehaviour;
  var CStyleFoldMode = require("ace/mode/folding/cstyle").FoldMode;

  var Mode = function() {
    this.$tokenizer = new Tokenizer(new GraphQLHighlightRules().getRules());
    this.$outdent = new MatchingBraceOutdent();
    this.$behaviour = new CstyleBehaviour();
    this.foldingRules = new CStyleFoldMode();
  };

  oop.inherits(Mode, TextMode);

  (function() {
    this.getNextLineIndent = function(state, line, tab) {
      var indent = this.$getIndent(line);

      if (state == "start") {
        var match = line.match(/^.*[\{\(\[]\s*$/);

        if (match) {
          indent += tab;
        }
      }

      return indent;
    };

    this.checkOutdent = function(state, line, input) {
      return this.$outdent.checkOutdent(line, input);
    };

    this.autoOutdent = function(state, doc, row) {
      this.$outdent.autoOutdent(doc, row);
    };
  }).call(Mode.prototype);

  exports.Mode = Mode;
});

define('ace/mode/graphql_highlight_rules', function(require, exports, module) {
  "use strict";

  var oop = require("../lib/oop");
  var TextHighlightRules = require("./text_highlight_rules").TextHighlightRules;

  var GraphQLHighlightRules = function() {
    this.$rules = {
      "start": [
        {
          token: "comment.block",
          regex: "\\/\\*",
          next:  "rems"
        }, {
          token: "comment.line",
          regex: "\\/\\/",
          next:  "rem"
        }, {
          token: "string", // single line
          regex: '"',
          next:  "string"
        }, {
          token: "invalid.illegal", // single quoted strings are not allowed
          regex: "['](?:(?:\\\\.)|(?:[^'\\\\]))*?[']"
        }, {
          token: "constant.numeric",
          regex: "[+-]?\\d+(?:(?:\\.\\d*)?(?:[eE][+-]?\\d+)?)?\\b"
        }, {
          token: "constant.language.boolean",
          regex: "(?:true|false)\\b"
        }, {
          token: "constant.language",
          regex: "(?:null)\\b"
        }, {
          token: "keyword.operator",
          regex: "(?:[aA][sS]|=)\\b"
        }, {
          token: "identifier",
          regex: "[a-zA-Z_][a-zA-Z0-9_]*"
        }, {
          token: "paren.lparen",
          regex: "[[({]"
        }, {
          token: "paren.rparen",
          regex: "[\\])}]"
        }, {
          token: "punctuation.operator",
          regex: "[\\.,]"
        }, {
          token: "text",
          regex: "\\s+"
        }, {
          token: "invalid.illegal",
          regex: "\\."
        }
      ],

      "rems": [
        {
          token: "comment.block",
          regex: "\\*\\/",
          next:  "start"
        }, {
          token: "comment.block",
          regex: ".*(?=\\*\\/)"
        }, {
          token: "comment.block",
          regex: ".+(?=$|\\n)"
        }, {
          token: "comment.block",
          regex: "$|\\n"
        }
      ],

      "rem": [
        {
          token: "comment.line",
          regex: "$|\\n",
          next:  "start"
        }, {
          token: "comment.line",
          regex: ".*(?=$|\\n)"
        }
      ],

      "string": [
        {
          token: "constant.language.escape",
          regex: /\\(?:x[0-9a-fA-F]{2}|u[0-9a-fA-F]{4}|["\\\/bfnrt])/
        }, {
          token: "string",
          regex: '[^"\\\\]+'
        }, {
          token: "string",
          regex: '"',
          next:  "start"
        }, {
          token: "string",
          regex: "",
          next:  "start"
        }
      ]
    };
  };

  oop.inherits(GraphQLHighlightRules, TextHighlightRules);
  exports.GraphQLHighlightRules = GraphQLHighlightRules;
});

function makeid(length) {
  length = length || 16;

  var id = '';
  var possible = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';

  for (var i = 0; i < length; i++) {
    id += possible.charAt(Math.floor(Math.random() * possible.length));
  }

  return id;
}

var Editor = React.createClass({
  getDefaultProps: function() {
    return {
      mode: 'text',
      value: '',
      readOnly: false,
      showGutter: false,
      highlightActiveLine: false,
      fontSize: 16,
      onChange: null
    };
  },

  getEditorId: function() {
    this.editorId = this.editorId || makeid();
    return this.editorId;
  },

  componentDidMount: function() {
    this.editor = ace.edit(this.getEditorId());
    this.editor.getSession().setMode('ace/mode/' + this.props.mode);
    this.editor.getSession().setTabSize(2);
    this.editor.setTheme('ace/theme/github');
    this.editor.setShowPrintMargin(false);
    this.editor.setFontSize(this.props.fontSize);
    this.editor.setReadOnly(this.props.readOnly);
    this.editor.setHighlightActiveLine(this.props.highlightActiveLine);
    this.editor.renderer.setShowGutter(this.props.showGutter);
    this.editor.on('change', this.handleChanged);
    this.editor.setValue(this.props.value);
    this.editor.selection.selectFileStart();

    $(React.findDOMNode(this)).data('ace', this.editor);
  },

  componentWillReceiveProps: function(nextProps) {
    this.editor.getSession().setMode('ace/mode/' + nextProps.mode);
    this.editor.setFontSize(nextProps.fontSize);
    this.editor.setReadOnly(nextProps.readOnly);
    this.editor.setHighlightActiveLine(nextProps.highlightActiveLine);
    this.editor.renderer.setShowGutter(nextProps.showGutter);

    if (this.editor.getValue() !== nextProps.value) {
      this.editor.setValue(nextProps.value);
      this.editor.selection.selectFileStart();
    }
  },

  componentWillUnmount: function() {
    this.editor.destroy();
  },

  render: function() {
    return (
      <div id={this.getEditorId()}></div>
    );
  },

  handleChanged: function() {
    var value = this.editor.getValue();

    if (this.props.onChange) {
      this.props.onChange(value);
    }
  }
});

var QuerySelector = React.createClass({
  render: function() {
    var options = this.props.queries.map(function(query, i) {
      return <option key={i} value={query.value}>{query.name}</option>;
    });

    return (
      <div>
        <label htmlFor="query-selector">Select a query: </label>

        <select id="query-selector" ref="selector" onChange={this.handleSelected}>
          <option value="">---</option>
          {options}
        </select>
      </div>
    );
  },

  handleSelected: function(e) {
    if (e.target.value.length) {
      this.props.querySelected(e.target.value);
    }
  }
});

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
    return (
      <form onSubmit={this.handleSubmit}>
        <h1>GQL Demo Application</h1>

        <div className="panels">
          <div className="left-panel">
            <h2>Query</h2>
            <Editor name="query" mode="graphql" value={this.state.query} onChange={this.handleQueryChanged} showGutter highlightActiveLine />
            <QuerySelector queries={queries} querySelected={this.handleQueryChanged} />
          </div>

          <div className="center-panel">
            <h2>&nbsp;</h2>
            <button type="submit" className="execute" title="Execute Query">»</button>
          </div>

          <div className="right-panel">
            <h2>Result</h2>
            <Editor name="result" mode="json" value={this.state.result} readOnly />
            <p className="reset-note">All data will be reset daily at 08:00 UTC.</p>
          </div>
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

  handleQueryChanged: function(queryString) {
    this.setState({ query: queryString });
  },

  adjustControlHeights: function() {
    var preferredHeight = $(window).height() - 200;

    $('.ace_editor, .execute').height(preferredHeight);

    $('.ace_editor').each(function() {
      $(this).data('ace').resize();
    });
  }
});

React.render(<App />, document.getElementById('root'));
