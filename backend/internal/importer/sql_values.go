package importer

import (
	"errors"
	"regexp"
	"strconv"
	"strings"
	"time"
)

var shortTZSuffixPattern = regexp.MustCompile(`([+-]\d{2})$`)

type Value struct {
	Text      string
	IsNull    bool
	IsDefault bool
}

func (v Value) String() string {
	return v.Text
}

func (v Value) Int() (int, error) {
	if v.IsNull || v.IsDefault {
		return 0, nil
	}
	return strconv.Atoi(v.Text)
}

func (v Value) Float64() (float64, error) {
	if v.IsNull || v.IsDefault {
		return 0, nil
	}
	return strconv.ParseFloat(v.Text, 64)
}

func (v Value) Bool() (bool, error) {
	if v.IsNull || v.IsDefault {
		return false, nil
	}
	return strconv.ParseBool(v.Text)
}

func (v Value) Time() (time.Time, error) {
	if v.IsNull || v.IsDefault {
		return time.Time{}, nil
	}
	return time.Parse(time.RFC3339Nano, normalizeSQLTime(v.Text))
}

func ParseInsertValues(line string, prefix string) ([]Value, error) {
	if !strings.HasPrefix(line, prefix) {
		return nil, errors.New("line does not match insert prefix")
	}

	trimmed := strings.TrimSuffix(strings.TrimSpace(strings.TrimPrefix(line, prefix)), ";")
	if !strings.HasPrefix(trimmed, "(") || !strings.HasSuffix(trimmed, ")") {
		return nil, errors.New("insert values tuple not wrapped in parentheses")
	}
	trimmed = strings.TrimPrefix(trimmed, "(")
	trimmed = strings.TrimSuffix(trimmed, ")")

	var (
		values  []Value
		current strings.Builder
		inQuote bool
	)

	for index := 0; index < len(trimmed); index++ {
		ch := trimmed[index]
		if inQuote {
			if ch == '\'' {
				if index+1 < len(trimmed) && trimmed[index+1] == '\'' {
					current.WriteByte('\'')
					index++
					continue
				}
				inQuote = false
				continue
			}
			current.WriteByte(ch)
			continue
		}

		switch ch {
		case '\'':
			inQuote = true
		case ',':
			values = append(values, parseRawValue(current.String()))
			current.Reset()
		default:
			current.WriteByte(ch)
		}
	}

	if inQuote {
		return nil, errors.New("unterminated quoted string")
	}
	values = append(values, parseRawValue(current.String()))
	return values, nil
}

func parseRawValue(raw string) Value {
	trimmed := strings.TrimSpace(raw)
	switch trimmed {
	case "NULL":
		return Value{IsNull: true}
	case "DEFAULT":
		return Value{IsDefault: true}
	default:
		return Value{Text: trimmed}
	}
}

func normalizeSQLTime(value string) string {
	if strings.Contains(value, "T") {
		return shortTZSuffixPattern.ReplaceAllString(value, "${1}:00")
	}
	value = strings.Replace(value, " ", "T", 1)
	return shortTZSuffixPattern.ReplaceAllString(value, "${1}:00")
}
