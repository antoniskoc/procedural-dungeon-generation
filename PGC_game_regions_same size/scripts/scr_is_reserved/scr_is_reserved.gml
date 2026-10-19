function scr_is_reserved(_tx, _ty)
    {
        // Cross corridor (keep clear route to doors)
        if (_tx == _tx1 || _tx == _tx2) return true;
        if (_ty == _ty1 || _ty == _ty2) return true;

        // Safe zone around the centre area (small rectangle)
        if (_tx >= _tx1 - 1 && _tx <= _tx2 + 1 && _ty >= _ty1 - 1 && _ty <= _ty2 + 1) return true;

        return false;
    }
