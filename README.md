Scenario
========

Scenario provides tools for handling stories with *event machine* whithout spaghettis.

Names use kitchen's latin, because it's more leet then japanese words.

Ruby 1.9.2 is used, it may work with ruby 1.8.x

Scenario use the bleeding edge version of event machine, the 1.0.0.beta3, with few informations from Google, checkout the source and build the doc yourself.
Some of this patterns are now in Event Machine, with a verbose syntax and without chainability. I'll try to don't rebuild the wheel and use it.

Tools
-----

### Multi

Just like the Multi tool in _em-http-request_ and _em-synchrony_.
You can launch any deferrable.

```ruby
EM.run do
  m = EM::Scenario::Multi.new
  stack = []
  m.add(EM::Scenario::Timer.new(Random.rand(0.1)) do
    stack << 1
  end)
  m.add(EM::Scenario::Timer.new(Random.rand(0.1)) do
    stack << 2
  end)
  m.add(EM::Scenario::Timer.new(Random.rand(0.1)) do
    stack << 3
  end)
  m.callback do
    assert [1,2,3] == stack.sort
    EM.stop
  end
end
```

Syntax sugar can hide the boiler plate

```ruby
EM.run do
  stack = []
  # Throw some Deferrables
  a = EM::Scenario::Timer.new(Random.rand(0.1)){ stack << 1}
  b = EM::Scenario::Timer.new(Random.rand(0.1)){ stack << 2}
  c = EM::Scenario::Timer.new(Random.rand(0.1)){ stack << 3}
  d = EM::Scenario::Timer.new(Random.rand(0.1)){ stack << 4}
  # and join them
  EM::Scenario.join(a, b, c, d) do
    assert (1..4).to_a == stack.sort
    EM.stop
  end
end
```

### Sequence

No stairs, just a sequence of deferrables.

```ruby
EM.run do
  stack = []
  EM::Scenario::Sequence.new do
    EM::Scenario::Timer.new(0.4) do
      stack << 1
    end
  end.then do
    EM::Scenario::Timer.new(0.3) do
      stack << 2
    end
  end.then do |iter|
    EM::Scenario::Timer.new(0.2) do
      stack << 3
      iter.return 42 #you can return values for the next step
    end
  end.then do |iter, n|
    assert n == 42 # and retrieve it
    EM::Scenario::Timer.new(0.1) do
      stack << 4
    end
  end.then do
    assert (1..4).to_a == stack
    EM.stop
  end
end
```

### Mixing multis and sequences

`Multi` and `Sequence` handle any deferrable objects and are deferrable too. You can compound story :

```
    /-#-\   /-#-#--\
 -#---#---#----#-----#-
    \-#-/   \----#-/

```

```ruby
EM.run do
  stack = []
  EM::Scenario::Sequence.new do
    m = EM::Scenario::Multi.new
    10.times do
      m.add(rand_timer(0.5) { stack << 0 })
    end
    m
  end.then do
    m = EM::Scenario::Multi.new
    10.times do
      m.add(rand_timer(0.5) { stack << 1 })
    end
    m
  end.then do
    rand_timer(0.5) do
      assert [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1] == stack
      EM.stop
    end
  end
end
```

Experimentations
----------------

Strange and experimental tools with strange names. Most are specific and redundant iterator. Some guinea pigs could die soon.

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
