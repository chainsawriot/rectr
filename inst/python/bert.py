import torch
from transformers import *

model_class, tokenizer_class = (BertModel, BertTokenizer)

model = model_class.from_pretrained("bert-base-multilingual-cased")
tokenizer = tokenizer_class.from_pretrained("bert-base-multilingual-cased")

def bert_word(text, model = BertModel.from_pretrained("bert-base-multilingual-cased"), tokenizer = BertTokenizer.from_pretrained("bert-base-multilingual-cased")):
    return(pipeline("feature-extraction", model = model, tokenizer = tokenizer)(text))

# def bert_sentence(text, model = BertModel.from_pretrained("bert-base-multilingual-cased"), tokenizer = BertTokenizer.from_pretrained("bert-base-multilingual-cased"), max_length = 512):
#     input_ids = tokenizer.encode(text, add_special_tokens = True, max_length = max_length, return_tensors = 'pt')		
#     with torch.no_grad():
#         output_tuple = model(input_ids)
#     output = output_tuple[0].squeeze()
#     output = output.mean(dim = 0)
#     output = output.numpy()
#     return(output)

def bert_sentence(content, model = BertModel.from_pretrained("bert-base-multilingual-cased"), tokenizer = BertTokenizer.from_pretrained("bert-base-multilingual-cased"), max_length = 512, noise = True):
    """Assuming content to be a vector of text from R"""
    sentence_tensors = []
    if noise:
        print(content[0])
    for text in content:
        input_ids = tokenizer.encode(text, add_special_tokens = True, max_length = max_length, return_tensors = 'pt')		
        with torch.no_grad():
            output_tuple = model(input_ids)
        output = output_tuple[0].squeeze()
        sentence_tensors.append(output)
    emb_torch = torch.cat(sentence_tensors, 0)
    if noise:
        print(emb_torch.size())
    doc_emb = emb_torch.mean(dim = 0)
    res = doc_emb.numpy()
    return(res)

def bert_corpus(corpus, model = BertModel.from_pretrained("bert-base-multilingual-cased"), tokenizer = BertTokenizer.from_pretrained("bert-base-multilingual-cased"), max_length = 512):
    res = []
    for content in corpus:
        output = bert_sentence(content = content, model = model, tokenizer = tokenizer, max_length = max_length)
        res.append(output)
    return(res)

def bert_tokenize(text, tokenizer = BertTokenizer.from_pretrained("bert-base-multilingual-cased")):
    return tokenizer.encode(text, add_special_tokens = False)

# def masked(text, model = BertModel.from_pretrained("bert-base-multilingual-cased"), tokenizer = BertTokenizer.from_pretrained("bert-base-multilingual-cased")):
#     return(pipeline("fill-mask", model = model, tokenizer = tokenizer)(text))


# input_ids = tokenizer.encode("Hello a!", add_special_tokens = True, max_length = 512, return_tensors = "pt")

# with torch.no_grad():
#     output_tuple = model(input_ids)

# cls1 = output_tuple[0].squeeze()[0]

# input_ids = tokenizer.encode("Ciao!", add_special_tokens = True, max_length = 512, return_tensors = "pt")

# with torch.no_grad():
#     output_tuple = model(input_ids)

# cls2 = output_tuple[0].squeeze()[0]
