Scenario
========

Scenario provides tools for handling stories with *event machine* whithout spaghettis.

Names use kitchen's latin, because it's more leet then japanese words.

Ruby 1.9.2 is used, it may work with ruby 1.8.x

Scenario use the bleeding edge version of event machine, the 1.0.0.beta3, with few informations from Google, checkout the source and build the doc yourself.
Some of this patterns are now in Event Machine, with a verbose syntax and without chainability. I'll try to don't rebuild the wheel and use it.

Tools
-----

### Quorum

Do something when n actions are done.

```ruby
EM.run do
  quorum(5) do |nextStep|
      5.times do |i|
          EM.add_timer(Random.rand(0.1)) do
              nextStep.call
          end
      end
  end.finally do
      assert true
      EM.stop
  end
end

```

### AdNauseum

```ruby
EM.run do
    cpt = 0
    adnauseum do |nextStep|
        EM.add_timer(Random.rand(0.1)) do
            cpt += 1
            nextStep.call
        end
    end.until do
        cpt > 5
    end.finally do
        assert true
        EM.stop
    end
end
```

### AbInitio

Act sequentialy, from the start.

```ruby
EM.run do
    txt = ""
    abinitio do |sequence|
        sequence.then do |nextStep|
            EM.add_timer(Random.rand(0.1)) do
                txt = "Hello "
                nextStep.call
            end
        end.then do |nextStep|
            EM.add_timer(Random.rand(0.1)) do
                txt += "World"
                nextStep.call
            end
        end.then do |nextStep|
            EM.add_timer(Random.rand(0.1)) do
                txt.upcase!
                nextStep.call
            end
        end
    end.finally do
        assert "HELLO WORLD" == txt
        EM.stop
    end
end
```

### AdLib

Repeat an action, seqentillay.

```ruby
EM.run do
    stack = []
    adlib(5) do |nextStep, i|
        stack << i
        EM.add_timer(Random.rand(0.1)) do
            nextStep.call
        end
   end.finally do
        assert true
        assert [0,1,2,3,4] == stack
        EM.stop
   end
end
```

### QuantumSatis

Not so many parallel actions

```ruby
EM.run do
    stack = []
    quantumsatis(5, 2) do |nextStep, i, workers|
        assert workers <= 2
        EM.add_timer(Random.rand(0.1)) do
            stack << i
            nextStep.call
        end
    end.finally do
        assert (0..4).to_a == stack.sort
        EM.stop
    end
end
```

Todo
----

 * Chain all commands
 * Alias in plain old english

Licence
-------

Released under the LGPL license.
