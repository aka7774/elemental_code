class ColabUiParser():
    """
  from colab_ui_parser import ColabUiParser
  parser = ColabUiParser()
  # begin copypaste
  parser.add_argument(...)
  parser.add_argument(...)
  parser.add_argument(...)
  # end copypaste
  parser.parse_args()
  """
    inputs = []
    options = []

    def add_argument(self, *args, **kwargs):
        option_string = max(args, key = len)

        if 'help' in kwargs:
            help = '#@markdown ' + kwargs['help']
            self.inputs.append(help)

        input_key = option_string.replace('-', '')

        if 'default' in kwargs and kwargs['default'] != None:
            value = kwargs['default']
        else:
            value = ''

        if 'action' in kwargs and kwargs['action'] in ['store_true', 'store_false']:
            param = '#@param {type:"boolean"}'
        elif "choices" in kwargs:
            param = '#@param [' + ', '.join(['"'+str(c)+'"' for c in kwargs['choices']]) + '] {allow-input: true}'
        else:
            param = '#@param {type:"string"}'
        
        input = f"{input_key} = '{value}'{param}"
        self.inputs.append(input)

        if 'default' in kwargs and kwargs['default'] == None:
            option = '  {'+option_string+'={'+input_key+'} if '+input_key+' else "" } \\'
        elif 'action' in kwargs and kwargs['action'] in ['store_true', 'store_false']:
            option = '  {'+option_string+'={'+input_key+'} if '+input_key+' else "" } \\'
        else:
            option = '  '+option_string+'={'+input_key+'} \\'
        self.options.append(option)

    def parse_args(self):
        print("\n".join(self.inputs))
        print("\n")
        print("\n".join(self.options))
