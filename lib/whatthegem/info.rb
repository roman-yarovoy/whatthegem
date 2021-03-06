module WhatTheGem
  class Info < Command
    register description: '(default) General information about the gem'

    # About info shortening: It is because minitest pastes their whole README
    # there, including a quotations of how they are better than RSpec.
    # (At the same time, RSpec's info reads "BDD for Ruby".)

    TEMPLATE = Template.parse(<<~INFO)
                Latest version: {{info.version}} ({{age}})
            Installed versions: {% if specs %}{{ specs | map:"version" | join: ", "}}{% else %}—{% endif %}
      {% if current %}
      Most recent installed at: {{current.dir}}
      {% endif %}
      {% unless bundled.type == 'nobundle' %}
                In your bundle: {% if bundled.type == 'notbundled' %}—{% else
      %}{{ bundled.version }} at {{ bundled.dir }}{% endif %}
      {% endunless %}

      Try also:
      {% for command in commands %}
        `whatthegem {{info.name}} {{command.handle}}` -- {{command.description}}{% endfor %}
    INFO

    def locals
      {
        info: gem.rubygems.info,
        age: age,
        specs: specs,
        current: specs.last,
        bundled: gem.bundled.to_h,
        commands: commands
      }
    end

    private

    def age
      gem.rubygems.versions
        .first&.dig(:created_at)
        &.then(&Time.method(:parse))&.then(&I.method(:ago_text))
    end

    def specs
      gem.specs.map { |spec|
        {
          name: spec.name,
          version: spec.version.to_s,
          dir: spec.gem_dir
        }
      }
    end

    def commands
      Command.registry.values.-([self.class]).map(&:meta).map(&:to_h)
    end
  end
end