# Quick Environment Test

This cell tests if the uv environment is properly set up with all required packages.

```python
try:
    # Test core imports
    import openai
    import azure.ai.projects
    import azure.ai.inference
    import azure.identity
    import pandas as pd
    import numpy as np
    
    print("✅ All core packages imported successfully!")
    print(f"✅ OpenAI version: {openai.__version__}")
    print(f"✅ Pandas version: {pd.__version__}")
    print(f"✅ NumPy version: {np.__version__}")
    
except ImportError as e:
    print(f"❌ Import error: {e}")
    print("Make sure you've run: uv sync")
```
